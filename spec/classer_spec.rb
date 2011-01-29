require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'url/classer'

describe "URL()" do
  
  before(:all) do
    class FacebookURL < URL('http://www.facebook.com')
      allow_changed :subdomain
      allow_params :foo
    end
  end
  
  it "should create a class" do
    url = 'http://www.facebook.com'
    u = URL.new(url)
    URL(u).should be_a(Class)
    
    URL.should_receive(:new,url).once
    URL(url).should be_a(Class)
  end
  
  context '.new' do
    subject {FacebookURL.new}
    
    it "shoud work like whatever" do
      subject.subdomain << 'us'
      subject.to_s.should =~ /^http:\/\/www\.us\.facebook.com\/?$/
    
      u = FacebookURL.new
      u.to_s.should =~ /^http:\/\/www\.facebook.com\/?$/
    end
  
    it "should dup" do
      subject.subdomain << 'us'
      d = subject.dup
      d.subdomain.should == ['www','us']
      
      d.subdomain << '1'
      d.subdomain.should == ['www','us','1']
      subject.subdomain.should == ['www','us']
    end
    
    it "should allow params" do
      subject.foo = 1
      subject.foo.should == 1
      subject.to_s.should =~ /foo=1/
    end
  end
  
end
