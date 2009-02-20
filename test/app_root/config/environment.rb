ENV['RAILS_ENV'] ||= 'in_memory'

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.cache_classes = false
  config.whiny_nils = true
  config.load_paths << File.join(File.dirname(__FILE__), '../../../lib')

  config.action_controller.session = {
    :key => '_item_session',
    :secret      => '1634aa213e0052cb68c48c1dd90e96303fa4566cf6726509d82a30fd5980c1971d2ce9017555b1d5f7a8a6ea07f1fe5e2f5f120579c10df764a46086f2afa371'
  }
end
