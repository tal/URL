class URL
  
  # Handlers for making requests for the URL. To create your own you need to follow the following conventions:
  # 1. You must define the get, post, and delete instance methods
  # 2. These methods should return a {Response} object
  # 
  # To create a {Response} object:
  #   hsh = {
  #     :code => resp.code,
  #     :time => resp.time,
  #     :body => resp.body,
  #     :response => resp,
  #     :url => url.to_s
  #   }
  #   Response.new(hsh)
  class RequestHandler
    attr_reader :url
    def initialize(url)
      @url = url
    end
    
    def get(args={})
      raise Exception, "You need to implement #{self.class}#get"
    end
    
    def post(args={})
      raise Exception, "You need to implement #{self.class}#post"
    end
    
    def delete(args={})
      raise Exception, "You need to implement #{self.class}#delete"
    end

    def put(args={})
      raise Exception, "You need to implement #{self.class}#put"
    end
  end
  
  class JSONHandler
    attr_reader :str
    def initialize(str)
      @str = str
    end
    
    def parse
      raise Exception, "You need to implement #{self.class}#parse"
    end
    
  end
  
end

Dir[File.join(File.dirname(__FILE__),'handlers','*.rb')].each {|f| require f}
