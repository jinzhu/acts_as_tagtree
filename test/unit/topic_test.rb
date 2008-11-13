require 'test_helper'

class TopicTest < ActiveSupport::TestCase
  should_have_db_columns :title
  should_have_many :taggings
  should_have_many :tags

end
