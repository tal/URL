class URL
  class ASJSONHandler < JSONHandler
    
    def parse
      ActiveSupport::JSON.decode(@str)
    end
    
  end
end
