require File.dirname(__FILE__) + '/app_root/config/environment'
require 'test_help'
require 'rubygems'
require 'shoulda'

# Run the migrations
ActiveRecord::Migration.verbose = false
ActiveRecord::Migrator.migrate("#{RAILS_ROOT}/db/migrate")

# Setup the fixtures path
Test::Unit::TestCase.fixture_path = File.join(File.dirname(__FILE__), "fixtures")
