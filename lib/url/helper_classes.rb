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
    
    # Merges the array into a parameter string of the form <tt>?key=value&foo=bar</tt>
    def to_s
      return '' if empty?
      '?' + to_a.inject(Array.new) do |ret,param|
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
    end
  end
end