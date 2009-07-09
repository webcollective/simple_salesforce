module SimpleSalesforce
  module SalesforceObject # :nodoc:

    class Base

      include Activation
      include Finders
      include CreatorsAndUpdaters
      include Destroyers

      def self.inherited(child)
        child.map_field :salesforce_id, :to_salesforce_field => :Id
      end

      def initialize(attributes = {})
        attributes.delete(:id)
        attributes.delete(:salesforce_id)
        attributes.each do |att, value|
          self.send("#{att}=", value)
        end
      end

    end

  end
end