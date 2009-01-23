require File.dirname(__FILE__) + '/../spec_helper'

describe CouchPotato::Persistence::ViewQuery, 'query_view' do
  before(:each) do
    @db = mock 'db'
    ::CouchPotato::Persistence.stub!(:Db).and_return(@db)
  end
  
  it "should not pass a key if conditions are empty" do
    @db.should_receive(:view).with(anything, {})
    CouchPotato::Persistence::ViewQuery.new('', '', '', '', {}).query_view!
  end
  
  it "should search by a range and a value at once" do
    @db.should_receive(:view).with(anything, {:startkey => ['123', 1], :endkey => ['123', 2]})
    CouchPotato::Persistence::ViewQuery.new('', '', '', '', {:position => 1..2, :album_id => '123'}).query_view!
  end
end