module SimpleSalesforce
  module SalesforceObject # :nodoc:

    module Destroyers
      
      def self.included(klass)
        klass.class_eval do
          include InstanceMethods
        end
      end
      
      module InstanceMethods
        
        # Destroy an existing SalesforceObject
        def destroy
          SimpleSalesforce::Binding.binding.delete :Id => self.salesforce_id
          destroyed_successfully = (response[:deleteResponse][:result][:success] == "true") rescue false
        end

      end
      
    end
  end
end