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
      s = @url.to_s
      s.should include 'https://mail.google.com:8080/foo/bar/baz?'
      s.should include 'q=one'
      s.should include 'foo=bar'
      s.should include '&'
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
  
  
  it "should should modify params easily" do
    @url[:foo] = '123'
    @url['foo'].should == '123'
    @url.to_s.should include('foo=123')
    
    @url['foo'] = '345'
    @url[:foo].should == '345'
    @url.to_s.should include('foo=345')
  end
  
  it "should should accept arbitrary req handlers" do
    class TestReq < URL::TyHandler; end
    @url.req_handler = TestReq
    @url.req_handler.should be_a(URL::RequestHandler)
    @url.req_handler.should be_instance_of(TestReq)
  end
  
  it "should should make sure there's always a path" do
    @url.path = nil
    @url.path.should == '/'
    
    @url.path = ''
    @url.path.should == '/'
  end
  
  it "should match =~" do
    (@url =~ /mail\.google\.com/).should == (@url.to_s =~ /mail\.google\.com/)
  end
  
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
    str.should include CGI.escape('test[]')+'=1'
    str.should include CGI.escape('test[]')+'=2'
    str.should include CGI.escape('test[]')+'=3'
  end
  
  it "should recursively make objects" do
    pending('implementation')
    hsh = URL::ParamsHash.new
    
    hsh[:test] = [{:foo => 'bar', :bar => 'baz'},{:foo => 'baz'}]
    hsh[:hash] = {:one => {'o' => 1}, :two => 2}
    
    str = hsh.to_s
    
    str.should include CGI.escape('test[][foo]')+'=bar'
    str.should include CGI.escape('test[][bar]')+'=baz'
    str.should include CGI.escape('test[][foo]')+'=baz'
    str.should include CGI.escape('hash[one][o]')+'=1'
    str.should include CGI.escape('hash[two]')+'=2'
  end
end