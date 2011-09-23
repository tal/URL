class URL
  class Service
    module AcceptsEndpoint

      # creates the endpoint for which ever object it's imported into
      def endpoint arg, &blk
        endpoint = if arg.is_a?(Hash)
          f = arg.first
          name = f.shift
          f.shift
        else
          name = arg
        end

        eigenclass.send :attr_reader, "#{name}_endpoint"
        instance_eval <<-RUBY, __FILE__, __LINE__
          def #{name} params=nil, args={}
            if params.nil?
              @#{name}_endpoint
            else
              @#{name}_endpoint.find(params,args)
            end
          end
        RUBY

        builder = EndpointBuilder.new(@base_url,endpoint,&blk)
        e = builder._endpoint
        
        e.inflate_into ||= @inflate_into if @inflate_into
        instance_variable_set "@#{name}_endpoint",e
      end

      # allows access to the eigenclass
      def eigenclass
        class << self; self; end
      end
    end
  end
end
