require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'url/classer'

describe "URL()" do
  
  before(:all) do
    class FacebookURL < URL('http://www.facebook.com/__test_me__/foo/__test_again__')
      allow_changed :subdomain
      allow_params :foo, :bar
    end
  end
  
  it "should create a class" do
    url = 'http://www.facebook.com'
    lambda {class FacebookURL2 < URL(url); end}.should_not raise_error
    
    FacebookURL2.new.to_s.should == 'http://www.facebook.com/'
    FacebookURL2.new.should be_a(URL::Classer)
  end
  
  context '.new' do
    subject {FacebookURL.new}
    
    it "shoud work like whatever" do
      subject.subdomain << 'us'
      subject.to_s.should =~ /^http:\/\/www\.us\.facebook.com/
    
      u = FacebookURL.new
      u.to_s.should =~ /^http:\/\/www\.facebook.com/
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
    
    it "should set vars" do
      subject.test_me = 'foobar'
      subject.test_me.should == 'foobar'
      
      subject.test_again = 'abc'
      subject.to_s.should == "http://www.facebook.com/foobar/foo/abc"
      
      subject.test_again = 'aaa'
      subject.to_s.should == "http://www.facebook.com/foobar/foo/aaa"
    end
    
    it "should set vars in create" do
      u = FacebookURL.new(:test_me => 'foobar', :test_again => 'abc')
      
      u.to_s.should == "http://www.facebook.com/foobar/foo/abc"
    end
  end
  
end
