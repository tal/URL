class URL
  class Service
    class EndpointBuilder
      attr_reader :_endpoint
      extend Forwardable

      # Create a method missing enironment to build out all the methods on the
      # endpoint object
      def initialize base_url, endpoint, params={}, &blk
        @url = base_url.dup
        @url.add_to_path endpoint.to_s
        @url.params.merge!(params)
        @_endpoint = Endpoint.new(@url)
        
        instance_eval &blk if block_given?
      end

      # Allow nesting of endpoints
      def_delegators :@_endpoint, :endpoint

      def returns arg=nil, &blk
        blk = arg unless block_given?
        @_endpoint.inflate_into = blk
      end

      # Build any additional methods sent
      def method_missing *args, &blk
        if m = caller.first.match(/^(#{__FILE__}:\d+):in `method_missing'$/) # protect against a typo within this function creating a stack overflow
          raise "Method missing calling itself with #{args.first} in #{m[1]}"
        end
        is_built_in = false
        # If you define a method named get,post,create,etc don't require the method type
        if Endpoint::BUILT_IN_METHODS.include?(args.first) && !Endpoint::BUILT_IN_METHODS.include?(args[1])
          name = args.shift

          if Endpoint::BUILT_IN_MAP.has_key?(name.to_sym)
            method = name.to_sym
            is_built_in = true
          else
            method = Endpoint::BULT_IN_MAP.find do |meth,aliases|
              aliases.include?(name)
            end

            method = method[0] if method
          end
        else
          name = args.shift
          method = args.shift if args.first.is_a?(Symbol)
        end
        name = name.to_sym

        method ||= :get
        
        options = args.shift||{}
        options[:requires] ||= []
        options[:requires] = [options[:requires]] unless options[:requires].is_a?(Array)
        options[:into] ||= blk if block_given?
        @_endpoint.method_inflate_into[name] = options[:into]

        @_endpoint.class_eval <<-RUBY, __FILE__, __LINE__
          def #{name} force_params={}, args={}
            params = #{(options[:default]||{}).inspect}.merge(force_params)
            #{(options[:requires]||[]).inspect}.each do |req|
              raise RequiredParameter, "#{name} endpoint requires the "<<req<<" paramerter" unless params.include?(req.to_sym) || params.include?(req.to_s)
            end

            if #{is_built_in.inspect}
              super(params,args)
            else
              transform_response(#{method}(params,args),method_inflate_into[#{name.inspect}])
            end
          end
        RUBY
      end

    end
  end
end
