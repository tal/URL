class URL
  class Service
    class Endpoint
      attr_reader :inflate_into
      
      {
        :get => %w{find},
        :post => %w{create},
        :put => %w{update},
        :delete => %w{destroy}
      }.each do |method,aliases|
        class_eval <<-RUBY
          def #{method} params = {}, opts = {}
            u = @url.dup
            u.params.merge! params

            u.#{method} opts
          end
        RUBY
        aliases.each do |al|
          class_eval <<-RUBY
            def #{al} params={}, opts={}
              transform_response #{method}(params, opts)
            end
          RUBY
        end
      end

      def initialize url
        @url = url
      end

      def class_eval *args,&blk
        eigenclass.class_eval *args,&blk
      end

      def eigenclass
        class << self; self; end
      end

    private
      
      def transform_response resp, into=nil
        resp = resp ? resp.json : nil
        if into ||= @inflate_into
          into.build(resp)
        else
          resp
        end
      end

      class << self
        
      end
    end
  end
end
