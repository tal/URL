require "delegate"

class URL
  
  class Response < DelegateClass(String) #:nodoc: all
    attr_reader :body,:time,:code,:response
    def initialize(str,args={})
      if str.is_a?(Hash)
        args = str
        str = args[:body]
      end
      
      raise unless str
      super(str)
      args.each do |key, value|
        instance_variable_set "@#{key}", value
      end
    end
    
    def success?
      return @successful if @successful
      
      code == 200
    end
  end
  
  class ParamsHash < Hash
    
    # Merges the array into a parameter string of the form <tt>?key=value&foo=bar</tt>
    def to_s
      return '' if empty?
      '?' + to_a.inject(Array.new) do |ret,param|
        val = param[1].to_s
        
        val = CGI.escape(val)# if val =~ /(\/|\?|\s)/
        
        if param && val
          ret << %{#{param[0].to_s}=#{val}}
        elsif param
          ret << param[0].to_s
        end
        ret
      end.join('&')
    end
  end
end