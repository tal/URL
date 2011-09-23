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

    def put(args={})
      resp = Typhoeus::Request.put(url.to_s, :body => url.params.to_s(false))
      make_str(resp)
    end

    def head(args={})
      resp = Typhoesu::Request.head(url.to_s)
      make_str(resp)
    end
    
  private
    
    def make_str(resp)
      hsh = {
        :code => resp.code,
        :time => resp.time,
        :body => resp.body,
        :response => resp,
        :url => url.to_s,
        :url_obj => url
      }
      
      Response.new(hsh)
    end
    
  end
end