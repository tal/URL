require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe URL do
  before do
    @url = URL.new('https://mail.google.com:8080/foo/bar/baz?q=one&foo=bar')
  end
  
  describe "#initialize" do
    it "should parse properly" do
      @url.params.should == {:q => 'one', :foo => 'bar'}
      @url.host.should == 'mail.google.com'
      @url.domain.should == 'google.com'
      @url.subdomain.should == ['mail']
      @url.port.should == '8080'
      @url.scheme.should == 'https'
    end
    
    it "should work with strange urls" do
      url = URL.new('http://one.mail.google.co.uk')
      url.domain.should == 'google.co.uk'
      url.subdomains.should == ['one','mail']

      url = URL.new('http://localhost')
      url.domain.should == 'localhost'
      url.subdomain.should be_nil
    end
  end
  
  describe '#to_s' do
    it "should roundtrip" do
      @url.to_s.should == 'https://mail.google.com:8080/foo/bar/baz?q=one&foo=bar'
    end
    
    it "should change and add params" do
      @url.params[:foo] = 'foo'
      @url.params[:baz] = 'baz'
      @url.port = '90'
      @url.subdomain = 'test'
      @url.scheme = 'ftp'
      @url.path = '/bar/baz'
      
      @url.to_s.should include 'ftp://test.google.com:90/bar/baz?'
      @url.to_s.should include 'q=one'
      @url.to_s.should include 'foo=foo'
      @url.to_s.should include 'baz=baz'
    end
  end
  
end

shared_examples_for "all requests" do
  it "should work" do
    @resp.should be_success
  end
  
  it "should have a response of the correct class" do
    @resp.response.should be_a(@resp_class)
  end
  
  it "shoudl have all attribures" do
    @resp.time.should be_a(Float)
    @resp.code.should be_a(Integer)
    @resp.url.should be_a(String)
  end
end

shared_examples_for "all builds" do
  
  
  before do
    @url = URL.new('http://www.omgpop.com')
  end
  
  describe "#get" do
    before do
      @resp = @url.get
    end
    it_should_behave_like "all requests"
  end
  
  describe "#post" do
    before do
      @resp = @url.post
    end
    it_should_behave_like "all requests"
  end
  
  describe "#delete" do
    before do
      @resp = @url.delete
    end
    it_should_behave_like "all requests"
  end
end

describe "Typhoeus", URL do
  before(:all) do
    require 'typhoeus'
    URL.req_handler = URL::TyHandler
    @resp_class = Typhoeus::Response
  end
  
  it_should_behave_like "all builds"
  
end


describe "Net::HTTP", URL do
  before(:all) do
    require 'net/http'
    URL.req_handler = URL::NetHandler
    @resp_class = Net::HTTPResponse
  end\
  
  it_should_behave_like "all builds"
  
end

describe URL::ParamsHash, '#to_s' do
  it "should make a param string" do
    hsh = URL::ParamsHash.new
    
    hsh[:foo] = 'bar'
    hsh[1] = 2
    
    str = hsh.to_s
    
    # str.should match(/^?/)
    str.should include('foo=bar')
    str.should include('1=2')
  end
  
  it "should make a param string with an array or hash" do
    hsh = URL::ParamsHash.new
    
    hsh[:test] = [*1..3]
    hsh[:hash] = {:one => 1, :two => 2}
    
    str = hsh.to_s
    
    str.should include CGI.escape('hash[one]')+'=1'
    str.should include CGI.escape('hash[two]')+'=2'
    str.should include CGI.escape('test[]')+'=1'+CGI.escape('test[]')+'=2'+CGI.escape('test[]')+'=3'
  end
  
  it "should recursively make make objects" do
    pending('implementation')
    hsh = URL::ParamsHash.new
    
    hsh[:test] = [{:foo => 'bar', :bar => 'baz'},{:foo => 'baz'}]
    hsh[:hash] = {:one => {'o' => 1}, :two => 2}
    
    str = hsh.to_s
    
    str.should include CGI.escape('test[][foo]')+'=bar&'+CGI.escape('test[][bar]')+'=baz&'+CGI.escape('test[][foo]')+'=baz'
    str.should include CGI.escape('hash[one][o]')+'=1'
    str.should include CGI.escape('hash[two]')+'=2'
  end
end