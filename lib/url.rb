require "net/http"
require "net/https"
require 'uri'
require 'cgi'

files = Dir.glob(File.join(File.dirname(__FILE__),'url','**','*.rb'))
files.each { |f| require f }

#:include: README.rdoc
class URL
  attr_reader :string, :params
  attr_accessor :subdomain, :domain, :path, :scheme, :format, :port, :hash
  alias_method :subdomains, :subdomain
  
  def initialize str
    @string = str
    sp = URI.split(@string)
    @scheme = sp[0]
    @port = sp[3]
    @path = sp[5]
    @format = @path.gsub(/(.+\.)/,'')
    @hash = sp[8]
    
    if sp[2]
      host_parts = sp[2].split('.')
      if host_parts[-2] == 'co'
        @domain = host_parts[-3,3].join('.')
        @subdomain = host_parts.first(host_parts.length-3)
      else
        begin
          @domain = host_parts[-2,2].join('.')
          @subdomain = host_parts.first(host_parts.length-2) 
        rescue # if there arent at least 2 parts eg: localhost
          @domain = host_parts.join('.')
        end
      end
    else
      @domain = nil
      @subdomain = nil
    end
    if sp[7]
      @params = sp[7].gsub('?','').split('&').inject(ParamsHash.new) do |result,param|
        key,value = param.split('=')
        value = CGI.unescape(value) if value
        result[key.to_sym] = value if key
        result
      end
    else
      @params = ParamsHash.new
    end
  end
  
  def host
    [@subdomain,@domain].flatten.compact.join('.')
  end
  
  # Outputs the full current url
  def to_s ops={}
    ret = String.new
    ret << %{#{scheme}://} if scheme && ops[:scheme] != false
    ret << host
    ret << %{:#{port}} if port && ops[:port] != false
    if path && ops[:path] != false
      ret << path
      # ret << %{.#{format}} if format && ops[:format] != false
    end
    
    ret << params.to_s if params && ops[:params] != false
    
    ret << "##{hash.to_s}" if hash && ops[:hash] != false
    
    ret
  end
  
  # Returns the parsed URI object for the string
  def to_uri
    URI.parse(to_s)
  end
  
  class << self
    attr_accessor :req_handler
  end
  
  def req_handler #:nodoc:
    self.class.req_handler.new(self)
  end
  
  # Performs a get request for the current URL
  def get(*args)
    req_handler.get(*args)
  end
  
  # Performs a post request for the current URL
  def post(*args)
    req_handler.post(*args)
  end
  
  # Performs a delete request for the current URL
  def delete(*args)
    req_handler.delete(*args)
  end
  
  if defined?(Typhoeus)
    self.req_handler = TyHandler
  else
    self.req_handler = NetHandler
  end
end

