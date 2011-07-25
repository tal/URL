require 'json'
require File.dirname(__FILE__) + '/spec_helper'

describe URL do
  context "A json response" do
    subject { URL.new('https://graph.facebook.com/37901410') }
    
    it "should parse json" do
      subject.get.json.should be_a(Hash)
    end
    
    it "should cache the json generation" do
      JSON.should_receive(:parse).once.and_return({})
      resp = subject.get
      resp.json
      resp.json
    end
  end
  
end
