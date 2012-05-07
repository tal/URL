require "net/http"
require "net/https"
require 'uri'
require 'cgi'
require 'forwardable'
require "delegate"

files = %w{
  version
  helper_classes
  handlers
  response
}
files.each { |f| require File.join(File.dirname(__FILE__),'url',f) }

# Main class for managing urls
#   url = URL.new('https://mail.google.com/mail/?shva=1#mbox')
#   url.params # => {:shva => '1'}
#   url.scheme # => 'https'
#   url.host   # => 'mail.google.com'
#   url.domain # => 'google.com'
#   url.subdomain # => ['mail']
#   url.path   # => '/mail/'
#   url.hash   # => 'mbox'
#
#   url.subdomain = ['my','mail']
#   url.params[:foo] = 'bar'
#   url.to_s   # => 'https://my.mail.google.com/mail/?foo=bar&shva=1#mbox'
class URL
  extend Forwardable
  attr_reader :string

  # The params for the request
  # @returns [URL::ParamsHash]
  attr_reader :params

  # Set the params for the request
  # Allows for url.params |= {:foo => 'bar'}
  # @returns [URL::ParamsHash]
  def params= p
    raise ArgumentError, 'Params must be a URL::ParamsHash' unless p.is_a?(ParamsHash)
    @params = p
  end

  # Attributes of the URL which are editable
  # @returns [String]
  attr_accessor :domain, :scheme, :format, :port, :hash

  # The path for the request
  # @returns [URL::Path]
  attr_reader :path

  # Set the path for the request
  def path=str
    if str.nil? || str.empty?
      str = '/'
    end

    @path = str
  end

  def add_to_path val
    unless @path[-1] == 47 # '/'
      @path << '/'
    end

    @path << val.sub(/^\//,'')
    @path
  end

  # Returns array of subdomains
  # @returns [URL::Subdomain]
  attr_reader :subdomain
  alias_method :subdomains, :subdomain

  # @param [Array,String] subdomain An array or string for subdomain
  def subdomain=(s)
    if s.is_a?(String)
      s = s.split('.')
    end

    @subdomain = s
  end
  alias_method :subdomains=, :subdomain=

  # Creates a new URL object
  # @param [String] URL the starting url to work with
  def initialize str
    @string = str
    sp = URI.split(@string)
    @scheme = sp[0]
    @port = sp[3]
    self.path = sp[5]
    @format = @path.gsub(/(.+\.)/,'')
    @hash = sp[8]

    if sp[2]
      host_parts = sp[2].split('.')
      # Detect internationl urls and treat as tld (eg .co.uk)
      if host_parts[-2] == 'co' and host_parts.length > 2
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

    @params = ParamsHash.new
    if sp[7]
      sp[7].gsub('?','').split('&').each do |myp|
        key,value = myp.split('=')
        value = CGI.unescape(value) if value
        @params[key.to_sym] = value if key
      end
    end
  end

  def_delegators :@params, :[], :[]=

  # The full hostname (not including port) for the URL
  def host
    [@subdomain,@domain].flatten.compact.join('.')
  end

  # Messed up host/hostname issue :(
  def host_with_port
    host<<':'<<port.to_s
  end

  # Outputs the full current url
  # @param [Hash] ops Prevent certain parts of the object from being shown by setting `:scheme`,`:port`,`:path`,`:params`, or `:hash` to `false`
  # @return [String]
  def to_s ops={}
    ret = String.new
    ret << %{#{scheme}://} if scheme && ops[:scheme] != false
    ret << host
    ret << %{:#{port}} if port && ops[:port] != false
    if path && ops[:path] != false
      ret << path
    end

    ret << params.to_s if params && ops[:params] != false

    ret << "##{hash.to_s}" if hash && ops[:hash] != false

    ret
  end

  # Returns the parsed URI object for the string
  # @return [URI]
  def to_uri
    URI.parse(to_s)
  end

  class << self
    # Define the request handler to use. If Typhoeus is setup it will use {TyHandler} otherwise will default back to Net::HTTP with {NetHandler}
    # @return [RequstHandler]
    def req_handler
      return @req_handler if @req_handler

      if defined?(Typhoeus)
        URL.req_handler = URL::TyHandler
      else
        URL.req_handler = URL::NetHandler
      end
    end

    # Define the request handler to use. If Typhoeus is setup it will use {TyHandler} otherwise will default back to Net::HTTP with {NetHandler}
    # @param [RequstHandler]
    # @return [RequstHandler]
    def req_handler=r
      raise ArgumentError, 'Must be a subclass of URL::RequestHandler' unless r.nil? || r < RequestHandler
      @req_handler = r
    end

    def json_handler
      return @json_handler if @json_handler

      if defined?(Yajl)
        URL.json_handler = URL::YajlHandler
      elsif defined?(JSON)
        URL.json_handler = URL::BaseJSONHandler
      elsif defined?(ActiveSupport::JSON)
        URL.json_handler = URL::ASJSONHandler
      end
    end

    def json_handler=r
      raise ArgumentError, 'Must be a subclass of URL::JSONHandler' unless r.nil? || r < JSONHandler
      @json_handler = r
    end
  end

  # Performs a get request for the current URL
  # @return [URL::Response] A subclass of string which also repsonds to a few added mthods storing more information
  def get(*args)
    req_handler.get(*args)
  end

  # Performs a post request for the current URL
  # @return [URL::Response] A subclass of string which also repsonds to a few added mthods storing more information
  def post(*args)
    req_handler.post(*args)
  end

  # Performs a delete request for the current URL
  # @return [URL::Response] A subclass of string which also repsonds to a few added mthods storing more information
  def delete(*args)
    req_handler.delete(*args)
  end

  # Performs a put request for the current URL
  # @return [URL::Response] A subclass of string which also repsonds to a few added mthods storing more information
  def put(*args)
    req_handler.delete(*args)
  end

  def inspect
    "#<#{self.class} #{to_s}>"
  end

  def dup
    URL.new(to_s)
  end

  # The request handler for this
  # @return [Handler]
  def req_handler
    (@req_handler||self.class.req_handler).new(self)
  end

  def =~ reg
    to_s =~ reg
  end

  # Sets the handler to use for this request
  # @param [RequstHandler]
  # @return [RequstHandler]
  def req_handler=r
    raise ArgumentError, 'Must be a subclass of URL::Handler' unless r < RequestHandler
    @req_handler = r
  end

end

