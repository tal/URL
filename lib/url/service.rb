class URL::Service
  INHERITED_INSTANCE_VARIABLES = {:@base_url=>:dup}

  class << self
    def set_url url
      unless url.is_a?(URL)
        url = URL.new(url)
      end
      @base_url = url
      self
    end

    def inherited(subclass)
      super
      ivs = subclass.instance_variables.collect{|x| x.to_s}
      INHERITED_INSTANCE_VARIABLES.each do |iv,dup|
        next if ivs.include?(iv.to_s)
        sup_class_value = instance_variable_get(iv)
        sup_class_value = sup_class_value.dup if dup == :dup && sup_class_value
        subclass.instance_variable_set(iv, sup_class_value)
      end
    end

    def endpoint arg, &blk
      endpoint = if arg.is_a?(Hash)
        f = arg.first
        name = f.shift
        f.shift
      else
        name = arg
      end

      builder = EndpointBuilder.new(@base_url,endpoint,&blk)

      e = builder.endpoint

      instance_variable_set "@#{name}_endpoint",e
      eigenclass.send :attr_reader, "#{name}_endpoint"
      instance_eval <<-RUBY
        def #{name} params=nil, args={}
          if params.nil?
            @#{name}_endpoint
          else
            @#{name}_endpoint.get(params,args)
          end
        end
      RUBY
    end

    def eigenclass
      class << self; self; end
    end

  end
end

class << URL
  def Service url
    Class.new(URL::Service).set_url(url)
  end
end
