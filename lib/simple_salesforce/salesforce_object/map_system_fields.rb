module SimpleSalesforce
  module SalesforceObject # :nodoc:

    class Base    

        # We always want to have a salesforce_id field linked to Salesforce's :Id field
        # eval "map_field :salesforce_id, :to_salesforce_field => :Id"  
        
    
    end
  end
end