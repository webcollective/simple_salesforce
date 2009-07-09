require File.dirname(__FILE__) + '/spec_helper'

Spec::Runner.configure do |config|
  config.mock_with :flexmock
end

describe "Destroying objects in Salesforce" do
  
  before(:all) do
    class MySalesforceContactToDestroy < SimpleSalesforce::SalesforceObject::Base
      use_salesforce_object "Contact"
      map_field :first_name, :to_salesforce_field => :FirstName
      map_field :last_name, :to_salesforce_field => :LastName
    end
    
    @horace = { :queryResponse=>{
                        :result=>{
                          :records=>
                            { :type=>"Contact", 
                              :FirstName=>"Horace", 
                              :LastName=>"Englebert", 
                              :Id=>"0038000000fgO1XAAU"
                            }, 
                          :done=>"true", 
                          :queryLocator=>nil, 
                          :size=>"1"
                        }
                      }
                    }

    @system_attributes = {:type => "Contact"}

    @success_response_destroyed = {:deleteResponse=>{:result=>{:success=>"true", :id=>"0038000000fgO1XAAU"}}}
  end

  before(:each) do
    @binding = flexmock(SimpleSalesforce::Binding.binding)    
  end
  
  it "should destroy an object in the Salesforce account" do
    @binding.should_receive(:query).once.and_return(@horace)
    @binding.should_receive(:delete).once.with({:Id => "0038000000fgO1XAAU"}).and_return(@success_response_destroyed)
    horace = MySalesforceContactToDestroy.find(:first)
    horace.destroy
  end  
   
end

