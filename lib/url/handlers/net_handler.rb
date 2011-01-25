class URL
  # Net::HTTP Handler
  class NetHandler < RequestHandler
    def get(args={})
      http = http_obj
      request = Net::HTTP::Get.new(make_path + url.params.to_s)
      t = Time.now
      resp = http.request(request)
      make_str(resp,Time.now-t)
    end
    
    def post(args={})
      http = http_obj
      request = Net::HTTP::Post.new(make_path)
      request.set_form_data(url.params)
      t = Time.now
      resp = http.request(request)
      make_str(resp,Time.now-t)
    end
    
    def delete(args={})
      http = http_obj
      request = Net::HTTP::Delete.new(make_path + url.params.to_s)
      t = Time.now
      resp = http.request(request)
      make_str(resp,Time.now-t)
    end
    
  private
  
    def make_path
      url.path
    end
    
    def make_str(resp,time)
      hsh = {
        :code => resp.code.to_i,
        :time => time,
        :body => resp.body,
        :response => resp,
        :url => url.to_s
      }
      
      Response.new(hsh)
    end
    
    def http_obj
      uri = url.to_uri
      http = Net::HTTP.new(uri.host,uri.port)
      
      if url.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      
      http
    end
  end
end