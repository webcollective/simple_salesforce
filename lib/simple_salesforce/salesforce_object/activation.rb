module SimpleSalesforce
  module SalesforceObject # :nodoc:

    module Activation
      
      def self.included(klass)
        klass.class_eval do
          extend Config
          include InstanceMethods
        end
      end
      
      module Config        

        def fields
          @fields
        end
        
        def salesforce_fields
          @fields.map {|field| field[:salesforce_field]}
        end

        def local_fields
          @fields.map {|field| field[:field]}
        end

        def to_salesforce_field(local_field)
          fields.select {|f| f[:field] == local_field.to_sym}.first[:salesforce_field]
        end
        
        def to_local_field(salesforce_field)
          fields.select {|f| f[:field] == salesforce_field.to_sym}.first[:local_field]
        end
        
        def salesforce_object_type
          @salesforce_object_type
        end
        
        def map_field(field, opts = {})
          @fields ||= Array.new
          @fields << {:field => field.to_sym, :salesforce_field => opts[:to_salesforce_field].to_sym || field}
          eval("attr_accessor :#{field}")
          #class_inheritable_accessor field.to_sym
        end
        
        def use_salesforce_object(object_type)
          @salesforce_object_type = object_type.to_s
          SimpleSalesforce::salesforce_objects << {:salesforce_object_type => object_type, :class_name => (name)  }
        end
                
      end
      
      module InstanceMethods
        
        def salesforce_object_type
          self.class.salesforce_object_type
        end
        
      end
            
    end

  end
end