module URL::Classer
  VAR_MATCHER = /__([A-Za-z]?[A-Za-z_]*[A-Za-z])__/
  
  module ClassMethods
    def allowed_params
      @allowed_params ||= []
    end
  private
    def allow_changed *args
      args.flatten!
      def_delegators :@url, :subdomains if args.include?(:subdomain)
      def_delegators :@url, :subdomain  if args.include?(:subdomains)
      def_delegators :@url, :[], :[]=   if args.include?(:params)
      def_delegators :@url, *args
    end
    
    def allow_params *args
      args.flatten.each do |arg|
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
    
    def overrideable_path_val v
      v = v.to_s.downcase
      define_method v do
        @var_map[v]
      end
      
      define_method "#{v}=" do |val|
        @var_map[v] = val
        
        p = self.class.const_get(:URL).path.dup
        
        @var_map.each do |key,value|
          p.gsub!("__#{key}__", value.to_s)
        end
        
        @url.path = p
        
        val
      end
    end
    
  end
  
  module InstanceMethods
    def initialize(opts={})
      @url = self.class.const_get(:URL).dup
      
      @var_map = {}
      
      opts.each do |op,v|
        send("#{op}=",v)
      end
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
  if url.is_a?(URL)
    url = url.dup
  else
    url = ::URL.new(url)
  end
  
  klass = Class.new do
    include URL::Classer
    
    vars = url.path.scan(URL::Classer::VAR_MATCHER).flatten
    
    vars.each do |var|
      overrideable_path_val(var)
    end
  end
  
  klass.const_set(:URL, url.freeze)
  
  klass
end
