class URL
  class Service
    class EndpointBuilder
      attr_reader :endpoint
      def initialize base_url, endpoint, params={}, &blk
        @url = base_url.dup
        @url.add_to_path endpoint.to_s
        @url.params.merge!(params)
        @endpoint = Endpoint.new(@url)
        instance_exec &blk if block_given?
      end

      # class FooService < Service('http://foo_svc')
      #   endpoint :user => :foobar do
      #     admin :get, :default => {:role => 'admin'}, :requires => %w{user_id}
      #     destroy :post, :requires => %w{user_id}
      #   end

      #   endpoint :login do
      #     create :post, :requires => %w{user_id}
      #   end
      # end
      # FooService.user(:role => 'admin' ,:user_id => 1) # => get request to http://foo_svc/foobar?role=admin&user_id=1
      # FooService.user.admin(:user_id => 1)             # => get request to http://foo_svc/foobar?role=admin&user_id=1
      def method_missing *args
        if m = caller.first.match(/^(#{__FILE__}:\d+):in `method_missing'$/) # protect against a typo within this function creating a stack overflow
          raise "Method missing calling itself with #{args.first} in #{m[1]}"
        end
        name = args.shift
        method = args.first.is_a?(Symbol) ? args.shift : :get
        options = args.shift||{}
        ruby = <<-RUBY
          def #{name} force_params={}, args={}
            params = #{(options[:default]||{}).inspect}.merge(force_params)
            #{(options[:requires]||[]).inspect}.each do |req|
              raise "#{name} endpoint requires the "<<req<<" endpoint" unless params.include?(req)
            end
            transform_response(#{method}(params,args),#{options[:into].inspect})
          end
        RUBY
        @endpoint.class_eval ruby
      end
    end
  end
end
