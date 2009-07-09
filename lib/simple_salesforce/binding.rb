module SimpleSalesforce
  class Binding
    
    class << self

      def initialize_and_login
        binding = RForce::Binding.new SimpleSalesforce::SALESFORCE_ENDPOINT
        binding.login SimpleSalesforce::SALESFORCE_USERNAME, SimpleSalesforce::SALESFORCE_PASSWORD_WITH_TOKEN
        binding
      end
      
      def binding
        @binding ||= initialize_and_login
      end
      
    end
          
  end
end