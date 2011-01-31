class URL
  class BaseJSONHandler < JSONHandler
    
    def parse
      JSON.parse(@str)
    end
    
  end
end
