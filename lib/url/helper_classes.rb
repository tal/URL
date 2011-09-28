class URL
  
  # A hash where all keys are symbols
  class Mash < Hash
    # Set the value of a param
    def []=(k,v)
      k = k.to_s.to_sym unless k.is_a?(Symbol)
      super(k,v)
    end
    
    # Read the value of a param
    def [](k)
      k = k.to_s.to_sym unless k.is_a?(Symbol)
      super(k)
    end
  end
  
  class ParamsHash < Mash
    def | other
      unless other.is_a? ParamsHash
        other = other.to_hash if other.respond_to?(:to_hash)
        other = ParamsHash[other]
      end
      other.merge(self)
    end

    def reverse_merge! other
      replace self|other
    end

    # Merges the array into a parameter string of the form <tt>?key=value&foo=bar</tt>
    def to_s(questionmark=true)
      return '' if empty?
      str = questionmark ? '?' : ''
      str << to_a.inject(Array.new) do |ret,param|
        key = param[0].to_s
        val = param[1]
        
        if param && val
          if val.is_a?(Hash)
            # TODO: Make this recusrive
            val.each do |param_key,param_val|
              param_key = CGI.escape("#{key}[#{param_key}]")
              param_val = CGI.escape(param_val.to_s)
              ret << %Q{#{param_key}=#{param_val}}
            end
          elsif val.is_a?(Array)
            # TODO: Make this recusrive
            val.each_with_index do |param_val,i|
              param_key = CGI.escape("#{key}[]")
              param_val = CGI.escape(param_val.to_s)
              ret << %Q{#{param_key}=#{param_val}}
            end
          else
            val = val.to_s

            val = CGI.escape(val)# if val =~ /(\/|\?|\s)/
            ret << %{#{param[0].to_s}=#{val}}
          end
        elsif param
          ret << param[0].to_s
        end
        ret
      end.join('&')
      str
    end
    
    class << self
      def from_string str
        params = URL::ParamsHash.new
        str.split('&').each do |myp|
          key,value = myp.split('=')
          value = CGI.unescape(value) if value
          params[key.to_sym] = value if key
        end
        params
      end
    end
    
  end
end