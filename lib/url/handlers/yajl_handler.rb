class URL
  class YajlHandler < JSONHandler
    
    def parse
      parser.parse(@str.to_s)
    end
    
  private
    def parser
      @parser ||= Yajl::Parser.new
    end
  end
end
