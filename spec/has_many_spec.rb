require File.dirname(__FILE__) + '/spec_helper'

class Office
  include CouchPotato::Persistence
  
  has_many :coworkers, :stored => :separately
  has_many :lights, :stored => :inline
end

class Light
  include CouchPotato::Persistence
  
  belongs_to :office
  
  property :power
end

class Coworker
  include CouchPotato::Persistence
  
  belongs_to :office
  
  property :name
end

describe 'has_many stored inline' do
  before(:each) do
    @office = Office.new
  end
  
  it "should build child objects" do
    @office.lights.build(:power => '60W')
    @office.lights.first.class.should == Light
    @office.lights.first.power.should == '60W'
  end
  
  it "should add child objects" do
    @office.lights << Light.new(:power => '60W')
    @office.lights.first.class.should == Light
    @office.lights.first.power.should == '60W'
  end
  
  it "should persist child objects" do
    @office.lights.build(:power => '10W')
    @office.save!
    @office = Office.find @office._id
    @office.lights.first.class.should == Light
    @office.lights.first.power.should == '10W'
  end
end

describe 'has_many stored separately' do
  before(:each) do
    Office.db.delete!
    @office = Office.new
  end
  
  it "should build child objects" do
    @office.coworkers.build(:name => 'my name')
    @office.coworkers.first.class.should == Coworker
    @office.coworkers.first.name.should == 'my name'
  end
  
  it "should create child objects" do
    @office.save!
    @office.coworkers.create(:name => 'my name')
    @office = Office.find @office._id
    @office.coworkers.first.class.should == Coworker
    @office.coworkers.first.name.should == 'my name'
  end
  
  it "should create! child objects" do
    @office.save!
    @office.coworkers.create!(:name => 'my name')
    @office = Office.find @office._id
    @office.coworkers.first.class.should == Coworker
    @office.coworkers.first.name.should == 'my name'
  end
  
  it "should add child objects" do
    @office.coworkers << Coworker.new(:name => 'my name')
    @office.coworkers.first.class.should == Coworker
    @office.coworkers.first.name.should == 'my name'
  end
  
  describe "all" do
    before(:each) do
      Office.db.delete!
    end
    
    it "should find all dependent objects by search conditions" do
      p 'XXXXXXXXXXXXXXXXXXXXXXX'
      office = Office.create!
      coworker1 = office.coworkers.create! :name => 'alex'
      coworker2 = office.coworkers.create! :name => 'alex'
      office.coworkers.create! :name => 'mathias'
      p 'MMMMMMMMMMMMMMMMMMMMMMMMMM'
      coworkers = office.coworkers.all(:name => 'alex')
      p 'MMMMMMMMMMMMMMMMMMMMMMMMMM'
      p coworkers.map(&:name)
      coworkers.size.should == 2
      coworkers.should include(coworker1)
      coworkers.should include(coworker2)
    end
    
    it "should return all dependent objects" do
      @office = Office.create!
      coworker1 = @office.coworkers.create! :name => 'my name'
      coworker2 = @office.coworkers.create! :name => 'my name2'
      coworkers = @office.coworkers.all
      coworkers.size.should == 2
      coworkers.should include(coworker1)
      coworkers.should include(coworker2)
    end    
  end
  
  describe "count" do
    before(:each) do
      Office.db.delete!
    end
    
    it "should count the dependent objects by search criteria" do
      office = Office.create!
      office.coworkers.create! :name => 'my name'
      office.coworkers.create! :name => 'my name'
      office.coworkers.create! :name => 'my name2'
      office.coworkers.count(:name => 'my name').should == 2
    end
    
    it "should count all dependent objects" do
      office = Office.create!
      office.coworkers.create! :name => 'my name'
      office.coworkers.create! :name => 'my name'
      office.coworkers.create! :name => 'my name2'
      office.coworkers.count.should == 3
    end
  end
  
  describe "first" do
    before(:each) do
      Office.db.delete!
    end
    after(:each) do
      Coworker.default_order = []
    end
    it "should find the first dependent object by search conditions" do
      office = Office.create!
      coworker1 = office.coworkers.create! :name => 'my name'
      coworker2 = office.coworkers.create! :name => 'my name2'
      office.coworkers.first(:name => 'my name2').should == coworker2
    end
    
    it "should return the first dependent object" do
      Coworker.default_order = [:_id]
      coworker1 = @office.coworkers.build :name => 'my name', :_id => '1'
      coworker2 = @office.coworkers.build :name => 'my name2', :_id => '2'
      @office.coworkers.first.should == coworker1
    end    
  end
  
  describe "create" do
    before(:each) do
      Office.db.delete!
    end
    it "should persist child objects" do
      @office.coworkers.build(:name => 'my name')
      @office.save!
      @office = Office.find @office._id
      @office.coworkers.first.class.should == Coworker
      @office.coworkers.first.name.should == 'my name'
    end

    it "should set the _id in child objects" do
      @office.coworkers.build(:name => 'my name')
      @office.save!
      @office.coworkers.first._id.should_not be_nil
    end

    it "should set the _rev in child objects" do
      @office.coworkers.build(:name => 'my name')
      @office.save!
      @office.coworkers.first._rev.should_not be_nil
    end

    it "should set updated_at in child objects" do
      @office.coworkers.build(:name => 'my name')
      @office.save!
      @office.coworkers.first.updated_at.should_not be_nil
    end

    it "should set created_at in child objects" do
      @office.coworkers.build(:name => 'my name')
      @office.save!
      @office.coworkers.first.created_at.should_not be_nil
    end
  end
  
  describe "update" do
    before(:each) do
      Office.db.delete!
    end
    it "should persist child objects" do
      coworker = @office.coworkers.build(:name => 'my name')
      @office.save!
      coworker.name = 'new name'
      @office.save!
      @office = Office.find @office._id
      @office.coworkers.first.name.should == 'new name'
    end
    
    it "should set the _rev in child objects" do
      coworker = @office.coworkers.build(:name => 'my name')
      @office.save!
      old_rev = coworker._rev
      coworker.name = 'new name'
      @office.save!
      @office.coworkers.first._rev.should_not == old_rev
    end

    it "should set updated_at in child objects" do
      coworker = @office.coworkers.build(:name => 'my name')
      @office.save!
      old_updated_at = coworker.updated_at
      coworker.name = 'new name'
      @office.save!
      @office.coworkers.first.updated_at.should > old_updated_at
    end
  end
  
  describe "destroy" do
    before(:each) do
      Office.db.delete!
    end
    
    class AdminCoworker
      include CouchPotato::Persistence
      belongs_to :admin
    end
    
    class AdminFriend
      include CouchPotato::Persistence
      belongs_to :admin
    end
    
    class Admin
      include CouchPotato::Persistence
      has_many :admin_coworkers, :stored => :separately, :dependent => :destroy
      has_many :admin_friends, :stored => :separately
    end
    
    it "should destroy all dependent objects" do
      admin = Admin.create!
      coworker = admin.admin_coworkers.create!
      id = coworker._id
      admin.destroy
      lambda {
        CouchPotato::Persistence.Db.get(id).should
      }.should raise_error(RestClient::ResourceNotFound)
    end
    
    it "should unset _id in dependent objects" do
      admin = Admin.create!
      coworker = admin.admin_coworkers.create!
      id = coworker._id
      admin.destroy
      coworker._id.should be_nil
    end
    
    it "should unset _rev in dependent objects" do
      admin = Admin.create!
      coworker = admin.admin_coworkers.create!
      id = coworker._id
      admin.destroy
      coworker._rev.should be_nil
    end

    it "should nullify independent objects" do
      admin = Admin.create!
      friend = admin.admin_friends.create!
      id = friend._id
      admin.destroy
      AdminFriend.get(id).admin.should be_nil
    end
  end
end