module URL::Classer
  module ClassMethods
    def allowed_params
      @allowed_params ||= []
    end
  private
    def allow_changed *args
      def_delegators :@url, :subdomains if args.include?(:subdomain)
      def_delegators :@url, :subdomain  if args.include?(:subdomains)
      def_delegators :@url, :[], :[]=   if args.include?(:params)
      def_delegators :@url, *args
    end
    
    def allow_params *args
      args.each do |arg|
        arg = arg.to_sym
        self.allowed_params << arg
        define_method arg do
          @url.params[arg]
        end
        
        define_method "#{arg}=" do |val|
          @url.params[arg] = val
        end
      end
    end
    
  end
  
  module InstanceMethods
    def initialize(opts={})
      @url = self.class.const_get(:URL).dup
      
      opts.delete_if do |k,v|
        !self.class.allowed_params.include?(k.to_sym)
      end
      
      @url.params.merge!(opts)
    end
    
    def to_s
      @url.to_s
    end
    
    def dup
      n_url = @url.dup
      n = super
      n.instance_variable_set(:@url, n_url)
      n
    end
    
  end
  
  def self.included(receiver)
    receiver.extend         Forwardable
    receiver.send :def_delegators, :@url, :get, :post, :delete, :inspect
    
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end

def URL url
  klass = Class.new
  
  if url.is_a?(URL)
    url = url.dup
  else
    url = URL.new(url)
  end
  
  klass.const_set(:URL, url)
  
  klass.send(:include, URL::Classer)
  
  klass
end
