require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe URL do
  before do
    @url = URL.new('https://mail.google.com:8080/foo/bar/baz?q=one&foo=bar')
  end
  
  it "should roundtrip" do
    @url.to_s.should == 'https://mail.google.com:8080/foo/bar/baz?q=one&foo=bar'
  end
  
  it "should parse properly" do
    @url.params.should == {:q => 'one', :foo => 'bar'}
    @url.host.should == 'mail.google.com'
    @url.domain.should == 'google.com'
    @url.subdomain.should == ['mail']
    @url.port.should == '8080'
    @url.scheme.should == 'https'
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
  
  it "should work with strange urls" do
    url = URL.new('http://one.mail.google.co.uk')
    url.domain.should == 'google.co.uk'
    url.subdomains.should == ['one','mail']
    
    url = URL.new('http://localhost')
    url.domain.should == 'localhost'
    url.subdomain.should be_nil
  end
end
