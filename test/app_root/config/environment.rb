ENV['RAILS_ENV'] ||= 'in_memory'

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.cache_classes = false
  config.whiny_nils = true
  config.load_paths << File.join(File.dirname(__FILE__), '../../../lib')
end
