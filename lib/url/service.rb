%w{
  accepts_endpoint
  endpoint
  endpoint_builder
}.each { |f| require File.join(File.dirname(__FILE__),f) }

class URL::Service
  INHERITED_INSTANCE_VARIABLES = {:@base_url=>:dup}
  extend AcceptsEndpoint
  class << self
    attr_accessor :config
    def set_url url
      unless url.is_a?(URL)
        url = URL.new(url)
      end
      @base_url = url
      self
    end

    def inherited(subclass)
      super


      if defined?(Rails) && File.exist?(Rails.root+'config/services.yml')
        self.config ||= YAML.load_file(Rails.root+'config/services.yml')[Rails.env] rescue nil

        if config
          target_name = subclass.to_s.demodulize.underscore
          service_url = config[target_name]||config[target_name.sub(/_service$/,'')]
        end
      end

      if service_url
        subclass.set_url service_url
      end

      ivs = subclass.instance_variables.collect{|x| x.to_s}
      INHERITED_INSTANCE_VARIABLES.each do |iv,dup|
        next if ivs.include?(iv.to_s)
        sup_class_value = instance_variable_get(iv)
        sup_class_value = sup_class_value.dup if dup == :dup && sup_class_value
        subclass.instance_variable_set(iv, sup_class_value)
      end
    end

  end

end

class << URL
  def Service url
    Class.new(URL::Service).set_url(url)
  end
end
