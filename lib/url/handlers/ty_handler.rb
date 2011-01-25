class URL
  # Typhoeus handler
  class TyHandler < RequestHandler
    
    def get(args={})
      resp = Typhoeus::Request.get(url.to_s)
      
      make_str(resp)
    end
    
    def post(args={})
      resp = Typhoeus::Request.post(url.to_s(:params => false), :params => url.params)
      
      make_str(resp)
    end
    
    def delete(args={})
      resp = Typhoeus::Request.delete(url.to_s)
      make_str(resp)
    end
    
  private
    
    def make_str(resp)
      hsh = {
        :code => resp.code,
        :time => resp.time,
        :body => resp.body,
        :response => resp,
        :url => url.to_s
      }
      
      Response.new(hsh)
    end
    
  end
end