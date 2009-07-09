require File.dirname(__FILE__) + '/spec_helper'

Spec::Runner.configure do |config|
  config.mock_with :flexmock
end

describe "Creating objects in Salesforce" do
  
  before(:all) do
    class MySalesforceContactToCreate < SimpleSalesforce::SalesforceObject::Base
      use_salesforce_object "Contact"
      map_field :first_name, :to_salesforce_field => :FirstName
      map_field :last_name, :to_salesforce_field => :LastName
    end
    
    @system_attributes = {:type => "Contact"}

    @success_response_created = {:createResponse=>{:result=>{:success=>"true", :id=>"0038000000fgO5XAAU"}}}
    @success_response_updated = {:updateResponse=>{:result=>{:success=>"true", :id=>"0038000000fgO5XAAU"}}}
  end

  before(:each) do
    @binding = flexmock(SimpleSalesforce::Binding.binding)    
  end
  
  it "should create an object with valid attributes in the Salesforce account" do
    attributes = {:first_name => "Jenni", :last_name => "Williams"}
    salesforce_attributes = {:FirstName => "Jenni", :LastName => "Williams"}
    @binding.should_receive(:create).once.with({:sObject => salesforce_attributes.merge(@system_attributes)}).and_return(@success_response_created)
    jenni = MySalesforceContactToCreate.create(attributes)
    jenni.should be_a(MySalesforceContactToCreate)
    jenni.first_name.should == "Jenni"
    jenni.last_name.should == "Williams"
    jenni.salesforce_id.should == "0038000000fgO5XAAU"
  end

  it "should raise and error when creating an object with invalid attributes in the Salesforce account" do
    attributes = {:first_name => "Jenni", :middle_name => "Horatio", :last_name => "Williams"}
    @binding.should_receive(:create).times(0)
    lambda {jenni = MySalesforceContactToCreate.create(attributes)}.should raise_error
  end

  it "should save a new object with valid attributes in the Salesforce account" do
    salesforce_attributes = {:FirstName => "Jenni", :LastName => "Williams"}
    @binding.should_receive(:create).once.with({:sObject => salesforce_attributes.merge(@system_attributes)}).and_return(@success_response_created)
    jenni = MySalesforceContactToCreate.new
    jenni.first_name = "Jenni"
    jenni.last_name = "Williams"
    jenni.should be_a(MySalesforceContactToCreate)
    jenni.save
  end

  it "should create and then update an existing object with valid attributes in the Salesforce account" do
    create_attributes = {:first_name => "Jenni", :last_name => "Williams"}
    salesforce_create_attributes = {:FirstName => "Jenni", :LastName => "Williams"}
    @binding.should_receive(:create).once.with({:sObject => salesforce_create_attributes.merge(@system_attributes)}).and_return(@success_response_created)
    jenni = MySalesforceContactToCreate.create(create_attributes)
    jenni.should be_a(MySalesforceContactToCreate)
    
    salesforce_update_attributes = {:FirstName => "Jennifer", :Id => "0038000000fgO5XAAU"}
    @binding.should_receive(:update).once.with({:sObject => salesforce_create_attributes.merge(salesforce_update_attributes).merge(@system_attributes)}).and_return(@success_response_updated)
    jenni.first_name = "Jennifer"
    jenni.save
  end
  
   
end

