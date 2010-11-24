class URL
  
  class Handler #:nodoc: all
    attr_reader :url
    def initialize(url)
      @url = url
    end
  end
  
  class TyHandler < Handler #:nodoc: all
    
    def get(args={})
      resp = Typhoeus::Request.get(url.to_s)
      
      make_str(resp)
    end
    
    def post(args={})
      resp = Typhoeus::Request.post(url.to_s(:params => false), :params => url.params)
      
      make_str(resp)
    end
    
    def delete
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
  
  class NetHandler < Handler #:nodoc: all
    def get(args={})
      puts 'net'
      http = http_obj
      request = Net::HTTP::Get.new(url.path + url.params.to_s)
      t = Time.now
      resp = http.request(request)
      make_str(resp,Time.now-t)
    end
    
    def post(args={})
      http = http_obj
      request = Net::HTTP::Post.new(url.path)
      request.set_form_data(url.params)
      t = Time.now
      resp = http.request(request)
      make_str(resp,Time.now-t)
    end
    
    def delete(args={})
      http = http_obj
      request = Net::HTTP::Delete.new(url.path + url.params.to_s)
      t = Time.now
      resp = http.request(request)
      make_str(resp,Time.now-t)
    end
    
  private
    
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