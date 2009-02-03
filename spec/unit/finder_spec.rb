require File.dirname(__FILE__) + '/../spec_helper'

describe CouchPotato::Persistence::Finder, 'find' do
  before(:each) do
    @database = stub 'database'
    ::CouchPotato::Persistence.stub!(:Db).and_return(@database)
  end
  
  it "should pass the count parameter to the database" do
    @database.should_receive(:view).with(anything, hash_including(:count => 1)).and_return({'rows' => []})
    CouchPotato::Persistence::Finder.new.find Comment, {}, :count => 1
  end
  
  it "should order the key alphabetically" do
    @database.should_receive(:view).with(anything, {:key => ['xyz', 'abc']}).and_return({'rows' => []})
    CouchPotato::Persistence::Finder.new.find Comment, {:name => 'xyz', :title => 'abc'}
  end
  
  it "should order by default order of class" do
    Comment.stub!(:default_order).and_return([:title])
    @database.should_receive(:view).with('comment/by_title', {:startkey => [nil], :endkey => ["\u9999"]}).and_return({'rows' => []})
    CouchPotato::Persistence::Finder.new.find Comment, {}
  end
end

describe CouchPotato::Persistence::Finder, "with sort" do
  before(:each) do
    @database = stub 'database'
    ::CouchPotato::Persistence.stub!(:Db).and_return(@database)
  end
  
  describe "query view" do
    it "should add the sort keys to the search keys" do
      @database.should_receive(:view).with(anything, {:startkey => [nil, 'xyz'], :endkey => ["\u9999", 'xyz']}).and_return({'rows' => []})
      CouchPotato::Persistence::Finder.new.find Comment, {:name => 'xyz'}, :order => [:title]
    end

    it "should search by sort keys without filtering" do
      @database.should_receive(:view).with(anything, {:startkey => [nil], :endkey => ["\u9999"]}).and_return({'rows' => []})
      CouchPotato::Persistence::Finder.new.find Comment, {}, :order => [:title]
    end

    it "should reorder existing search keys" do
      @database.should_receive(:view).with(anything, {:startkey => ['abc', 'xyz'], :endkey => ['abc', 'xyz']}).and_return({'rows' => []})
      CouchPotato::Persistence::Finder.new.find Comment, {:name => 'xyz', :title => 'abc'}, :order => [:title, :name]
    end
  end
  
  describe "create view" do
    before(:each) do
      @database.stub!(:view).and_raise(RestClient::ResourceNotFound)
    end
    
    it "should add the sort keys to the search keys" do
      @database.should_receive(:save) do |json|
        json[:views]['by_title_and_name'][:map].should include('[doc["title"], doc["name"]]')
      end
      begin
        CouchPotato::Persistence::Finder.new.find Comment, {:name => 'xyz'}, :order => [:title]
      rescue(RestClient::ResourceNotFound); end
    end

    it "should search by sort keys only" do
      @database.should_receive(:save) do |json|
        json[:views]['by_title'][:map].should include('doc["title"]')
      end
      begin
        CouchPotato::Persistence::Finder.new.find Comment, {}, :order => [:title] 
      rescue(RestClient::ResourceNotFound); end
    end

    it "should reorder existing search keys" do
      @database.should_receive(:save) do |json|
        json[:views]['by_title_and_name'][:map].should include('doc["title"], doc["name"]')
      end
      begin
        CouchPotato::Persistence::Finder.new.find Comment, {:name => 'xyz', :title => 'abc'}, :order => [:title, :name]
      rescue(RestClient::ResourceNotFound); end
    end
  end
end

