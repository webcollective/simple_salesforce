module SimpleSalesforce
  module SalesforceObject # :nodoc:

    module Finders
      
      def self.included(klass)
        klass.class_eval do
          extend ClassMethods
        end
      end
      
      module ClassMethods

        # Queries Salesforce and returns an instantiated object or an array of instantiated objects
        # Syntax find(:first, :conditions => {}), :find(:first, :conditions => ""), find(:all, :conditions => {}), find(:all, :conditions => "")
        def find(*args)
          options = args.extract_options!
          soql_conditions = construct_soql_conditions(options[:conditions])
          limit = options[:limit]
          case args.first
            when :all
              results = query_and_instantiate(:many, soql_conditions, limit)
            when :first
              results = query_and_instantiate(:one, soql_conditions, limit = 1)
            else
              # Find the object by its Salesforce Id and disregard :conditions and :limit
              # dontwork
              soql_conditions = construct_soql_conditions(:salesforce_id => args.first)
              results = query_and_instantiate(:one, soql_conditions, limit = 1)
            end
        end
        
        def method_missing(method_id, value)
          case method_id.to_s
            when /^find_(all_by|by)_([_a-zA-Z]\w*)$/
              finder = $1 == "all_by" ? :all : :first
              var = $2
              find(finder, :conditions => {var.to_sym => value})
            else
              super
          end
        end
        
        def query_and_instantiate(mode, soql_conditions, limit)
          # p construct_query_string(soql_conditions, limit) # debug
          query_response = SimpleSalesforce::Binding.binding.query :queryString => construct_query_string(soql_conditions, limit)
          case mode
          when :many
            instantiate_objects_from_query_response(query_response)
          when :one
            instantiate_single_object_from_query_response(query_response)
          end
        end
        
        # Figures out if the conditions are a single string (e.g. "Contact(FirstName) = 'Joe'") or a hash (e.g. #{:first_name => "Joe"})
        # If it's a hash, build the conditions out to SOQL
        def construct_soql_conditions(conditions = {})
          conditions = {} if conditions.nil?
          if conditions.is_a?(Hash)
            # It's a hash of conditions which we need to format, converting from local fieldnames to Salesforce object fieldnames in the process
            soql_conditions = format_conditions(conditions)
          else
            # It's probably a string, e.g. find(:all, :conditions => "Contact(FirstName) = 'Joe'")
            soql_conditions = [conditions]
          end
          soql_conditions.empty? ? [] : soql_conditions
        end
        
        # Returns an array of SOQL WHERE clause strings, given an array of hashes of the format #{:local_field => "value"}
        # This function interrogates the SalesforceObject Class to find the salesforce field for each local field
        def format_conditions(conditions)
          soql_conditions = []
          conditions.each do |local_field, value|
            salesforce_field = fields.select {|f| f[:field] == local_field.to_sym}.first[:salesforce_field] rescue nil
            soql_conditions << "#{salesforce_field} LIKE '#{value}'" unless salesforce_field.nil?
          end
          soql_conditions
        end

        # Construct SOQL query string from conditions array and limit number
        # The conditions array can be a single string or array of strings and will be joined with 'AND' if necessary
        def construct_query_string(soql_conditions, limit = nil)
          select_soql = "SELECT #{salesforce_fields.join(",")} "
          from_soql = "FROM #{salesforce_object_type}"
          where_soql = "#{' WHERE ' unless soql_conditions.empty?}#{soql_conditions.join(' AND ')}"
          limit_soql = "#{" LIMIT #{limit}" if limit}"
          "#{select_soql}#{from_soql}#{where_soql}#{limit_soql}"
        end
        
        # Return an array of SalesforceObjects of the appropriate class given a RForce response hash
        def instantiate_objects_from_query_response(response)
          records = extract_records_from_response(response)
          object_array = []
          if records.is_a?(Array)
            records.each {|r| object_array << instantiate_object_from_record(r)}
          else 
            object_array = [instantiate_object_from_record(records)]
          end
          object_array
        end
        
        # Return a single SalesforceObject of the appropriate class given a RForce response hash
        def instantiate_single_object_from_query_response(response)
          record = extract_records_from_response(response)
          instantiate_object_from_record(record)
        end

        # Get a single hash or array of hashed records from inside an RForce response hash
        def extract_records_from_response(response)
          raise SimpleSalesforce::SalesforceQueryFaultException , "Salesforce returned a query fault: #{response[:Fault][:faultcode]} : #{response[:Fault][:faultstring]}", caller if response[:Fault]
          begin
            # p response # debug
            records = response[:queryResponse][:result][:records]
          rescue SimpleSalesforce::UnexpectedSalesforceResponseException
            "Unexpected response from Salesforce: #{response.inspect}"
          end
        end
        
        # Given a hashed record, instantiate a SalesforceObject of the appropriate class
        # Hashed record is of the format #{:type=>"Contact", :FirstName=>"Joe", :Id=>"0038000000YkD6JAAV", :LastName=>"Bloggs"}
        def instantiate_object_from_record(record)
          class_name = self.name
          unless class_name.nil?
            current_object = eval "#{class_name}.new"
            current_object.class.fields.each do |field|
              eval "current_object.#{field[:field]} = record[field[:salesforce_field]]" rescue nil
            end
            current_object
          end
        end

      end
      
    end

  end
end