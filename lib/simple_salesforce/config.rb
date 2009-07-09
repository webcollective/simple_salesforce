module SimpleSalesforce
  
  config = YAML.load(File.open("#{RAILS_ROOT}/config/salesforce.yml"))[Rails.env].symbolize_keys
  SALESFORCE_USERNAME = config[:username].to_s
  SALESFORCE_PASSWORD = config[:password].to_s
  SALESFORCE_SECURITY_TOKEN = config[:security_token].to_s
  
  SALESFORCE_PASSWORD_WITH_TOKEN = "#{SALESFORCE_PASSWORD}#{SALESFORCE_SECURITY_TOKEN}"
  
  SALESFORCE_ENDPOINT = "https://www.salesforce.com/services/Soap/u/10.0"

  @salesforce_objects = []

  def self.salesforce_objects=(value)
    @salesforce_objects = value
  end
  
  def self.salesforce_objects
    @salesforce_objects
  end

end
