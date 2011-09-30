class URL
  class Service
    class Endpoint
      attr_accessor :inflate_into
      include AcceptsEndpoint

      # Storage for what each endpoint should inflate into
      def method_inflate_into
        @method_inflate_into ||= {}
      end

      # Define the built in methods and their fetcher aliases
      BUILT_IN_MAP = {
        :get => %w{find},
        :post => %w{create},
        :put => %w{update},
        :delete => %w{destroy}
      }.each do |method,aliases|
        class_eval <<-RUBY, __FILE__, __LINE__
          def #{method} params = {}, opts = {}
            u = @url.dup
            u.params.merge! params

            u.#{method} opts
          end
        RUBY
        aliases.each do |al|
          class_eval <<-RUBY, __FILE__, __LINE__
            def #{al} params={}, opts={}
              transform_response #{method}(params, opts)
            end
          RUBY
        end
      end.freeze

      BUILT_IN_METHODS = BUILT_IN_MAP.collect do |k,v|
        v.collect{|vv| vv.to_sym}+[k.to_sym]
      end.flatten.freeze

      def initialize url
        @base_url = @url = url
      end

      # Expose class eval externally
      def class_eval *args,&blk
        eigenclass.class_eval *args,&blk
      end

      def eigenclass
        class << self; self; end
      end

      def inspect
        %Q{#<#{self.class} #{@url.to_s}>}
      end

    private
      
      def transform_response resp, into=nil
        if resp.connection_refused
          raise EndpointNotResponding, resp.url_obj.host_with_port
        end

        if resp && !resp.empty?
          begin
            resp = resp.json
          rescue Exception => e
            warn "The response #{resp} couldn't be parsed"
            raise e
          end
        end
        
        if resp.is_a?(Hash) && (into ||= inflate_into)
          into.call(resp)
        else
          resp
        end
      end

      class << self
        
      end

      class RequiredParameter < RuntimeError; end
      class EndpointNotResponding < Errno::ECONNREFUSED; end
    end
  end
end
