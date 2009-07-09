# Simplesalesforce
if defined? RForce
  require File.dirname(__FILE__) + "/simple_salesforce/exceptions"
  require File.dirname(__FILE__) + "/simple_salesforce/binding"
  require File.dirname(__FILE__) + "/simple_salesforce/config"
  require File.dirname(__FILE__) + "/simple_salesforce/salesforce_object/base"
  require File.dirname(__FILE__) + "/simple_salesforce/salesforce_object/activation"
  require File.dirname(__FILE__) + "/simple_salesforce/salesforce_object/finders"
  require File.dirname(__FILE__) + "/simple_salesforce/salesforce_object/creators_and_updaters"
  require File.dirname(__FILE__) + "/simple_salesforce/salesforce_object/destroyers"
  require File.dirname(__FILE__) + "/simple_salesforce/salesforce_object/map_system_fields"
else
  message=%q(WARNING: simplesalesforce requires the RForce gem. You either don't have the gem installed, or you haven't told Rails to require it. If you're using a recent version of Rails: 
    config.gem "rforce" # in config/environment.rb
and of course install the gem: 
    sudo gem install rforce)
  puts message
  Rails.logger.error message
end