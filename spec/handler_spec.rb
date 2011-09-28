require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

shared_examples_for "all requests" do
  before do
    @resp = @url.send(@method)
  end
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

  it "should not error when making request" do
    test_connection_issue(@method)
  end

end

def test_connection_issue(sym)
  u = URL.new('http://localhost:5280')
  resp = nil
  expect {resp = u.send(sym)}.to_not raise_error
  resp.should_not be_successful
  resp.connection_refused.should be true
end

shared_examples_for "all builds" do
  
  
  before do
    @url = URL.new('http://www.omgpop.com')
  end
  
  describe "#get" do
    before do
      @method = :get
    end

    it_should_behave_like "all requests"
  end
  
  describe "#post" do
    before do
      @method = :post
    end
    it_should_behave_like "all requests"
  end
  
  describe "#delete" do
    before do
      @method = :delete
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
  end
  
  it_should_behave_like "all builds"
  
end
