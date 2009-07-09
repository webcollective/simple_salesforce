module SimpleSalesforce
  module SalesforceObject # :nodoc:

    module CreatorsAndUpdaters
      
      def self.included(klass)
        klass.class_eval do
          extend ClassMethods
          include InstanceMethods
        end
      end
      
      module ClassMethods

        # Create a new SalesforceObject from a hash of attributes
        # e.g. SalesforceContact.create(:first_name => "Joe", :last_name => "Bloggs")
        def create(attributes)
          object = new(attributes)
          object.save
          object
        end        

      end
      
      module InstanceMethods
        
        # Update an existing SalesforceObject with a hash of attributes, and save it
        def update_attributes(attributes)
          attributes.each do |att, value|
            send("#{att}=", value)
          end
          save
        end
        
        def new_record?
          salesforce_id.nil?
        end
        
        def save
          result = new_record? ? create : update
        end
        
      private

        def create
          attributes_for_create = build_salesforce_attributes
          # Response is of the format {:createResponse=>{:result=>{:success=>"true", :id=>"0038000000fgO5XAAU"}}}
          response = SimpleSalesforce::Binding.binding.create :sObject => attributes_for_create
          created_successfully = (response[:createResponse][:result][:success] == "true") rescue false
          if created_successfully
            @salesforce_id = response[:createResponse][:result][:id] rescue nil
          end
          created_successfully
        end
        
        def update
          attributes_for_update = build_salesforce_attributes
          response = SimpleSalesforce::Binding.binding.update :sObject => attributes_for_update
          updated_successfully = (response[:updateResponse][:result][:success] == "true") rescue false
          updated_successfully
        end
        
        def build_salesforce_attributes
          salesforce_attributes = {}
          self.class.local_fields.each do |local_field|
            salesforce_attributes[self.class.to_salesforce_field(local_field)] = send(:"#{local_field}") unless send(:"#{local_field}").nil?
          end
          salesforce_attributes[:type] = self.salesforce_object_type
          salesforce_attributes
        end
        
      end
      
    end
  end
end