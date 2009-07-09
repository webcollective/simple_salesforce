require File.dirname(__FILE__) + '/spec_helper'

Spec::Runner.configure do |config|
  config.mock_with :flexmock
end

describe "Finding objects from Salesforce" do
  
  before(:all) do
    class MySalesforceContactToFind < SimpleSalesforce::SalesforceObject::Base
      use_salesforce_object "Contact"
      map_field :first_name, :to_salesforce_field => :FirstName
      map_field :last_name, :to_salesforce_field => :LastName
    end
    
    @john = { :queryResponse=>{
                        :result=>{
                          :records=>
                            { :type=>"Contact", 
                              :FirstName=>"John", 
                              :LastName=>"Doe", 
                              :Id=>"0038000000YkD6JAAV"
                            }, 
                          :done=>"true", 
                          :queryLocator=>nil, 
                          :size=>"1"
                        }
                      }
                    }
                    
    @john_and_will =   { :queryResponse=>{
                          :result=>{
                            :records=>[
                              { :type=>"Contact", 
                                :FirstName=>"John", 
                                :LastName=>"Doe", 
                                :Id=>"0038000000YkD6JAAV"
                              }, 
                              { :type=>"Contact", 
                                :FirstName=>"Will", 
                                :LastName=>"Tomlinson", 
                                :Id=>"0038000000fgdg5AAA"
                              }
                            ], 
                            :done=>"true", 
                            :queryLocator=>nil, 
                            :size=>"2"
                          }
                        }
                      }


    @john_and_grace =   { :queryResponse=>{
                          :result=>{
                            :records=>[
                              { :type=>"Contact", 
                                :FirstName=>"John", 
                                :LastName=>"Doe", 
                                :Id=>"0038000000YkD6JAAV"
                              }, 
                              { :type=>"Contact", 
                                :FirstName=>"Grace", 
                                :LastName=>"Doe", 
                                :Id=>"0038000000fgdg6BBB"
                              }
                            ], 
                            :done=>"true", 
                            :queryLocator=>nil, 
                            :size=>"2"
                          }
                        }
                      }
    
  end

  before(:each) do
    @binding = flexmock(SimpleSalesforce::Binding.binding)    
  end
  
  it "should find all objects in the Salesforce account" do
    qs = "SELECT Id,FirstName,LastName FROM Contact"
    @binding.should_receive(:query).once.with({:queryString => qs}).and_return(@john_and_will)
    found_records = MySalesforceContactToFind.find(:all)
    found_records.size.should == 2
    found_records.each do |contact|
      contact.should be_a(MySalesforceContactToFind)
    end
    
  end
  
  it "should find the first object in the Salesforce account" do
    qs = "SELECT Id,FirstName,LastName FROM Contact LIMIT 1"
    @binding.should_receive(:query).once.with({:queryString => qs}).and_return(@john)
    found_contact = MySalesforceContactToFind.find(:first)
    found_contact.should be_a(MySalesforceContactToFind)
    found_contact.first_name.should == "John"
    found_contact.last_name.should == "Doe"
    found_contact.salesforce_id.should == "0038000000YkD6JAAV"
  end
  
  it "should find a single object by an attribute" do
    qs = "SELECT Id,FirstName,LastName FROM Contact WHERE LastName LIKE 'Doe' LIMIT 1"
    @binding.should_receive(:query).with({:queryString => qs}).once.and_return(@john)
    found_contact = MySalesforceContactToFind.find_by_last_name("Doe")
    found_contact.should be_a(MySalesforceContactToFind)
    found_contact.last_name.should == "Doe"
  end

  it "should find all objects by an attribute" do
    qs = "SELECT Id,FirstName,LastName FROM Contact WHERE LastName LIKE 'Doe'"
    @binding.should_receive(:query).with({:queryString => qs}).once.and_return(@john_and_grace)
    found_records = MySalesforceContactToFind.find_all_by_last_name("Doe")
    found_records.size.should == 2
    found_records.each do |contact|
      contact.should be_a(MySalesforceContactToFind)
      contact.last_name.should == "Doe"
    end
  end
  
  it "should find a single object using a conditions hash" do
    qs = "SELECT Id,FirstName,LastName FROM Contact WHERE LastName LIKE 'Doe' LIMIT 1"
    @binding.should_receive(:query).with({:queryString => qs}).once.and_return(@john)
    found_contact = MySalesforceContactToFind.find(:first, :conditions => {:last_name => "Doe"})
    found_contact.should be_a(MySalesforceContactToFind)
    found_contact.last_name.should == "Doe"
  end

  it "should find a all objects using a conditions hash" do
    qs = "SELECT Id,FirstName,LastName FROM Contact WHERE LastName LIKE 'Doe'"
    @binding.should_receive(:query).with({:queryString => qs}).once.and_return(@john_and_grace)
    found_records = MySalesforceContactToFind.find(:all, :conditions => {:last_name => "Doe"})
    found_records.size.should == 2
    found_records.each do |contact|
      contact.should be_a(MySalesforceContactToFind)
      contact.last_name.should == "Doe"
    end
  end
  
  it "should find all objects with a limit parameter" do
    qs = "SELECT Id,FirstName,LastName FROM Contact LIMIT 2"
    @binding.should_receive(:query).once.with({:queryString => qs}).and_return(@john_and_grace)
    found_records = MySalesforceContactToFind.find(:all, :limit => 2)
    found_records.size.should == 2
    found_records.each do |contact|
      contact.should be_a(MySalesforceContactToFind)
    end
  
  end

  
end

