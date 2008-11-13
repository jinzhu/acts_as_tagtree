require 'test_helper'

class TopicTest < ActiveSupport::TestCase
  should_have_db_columns :title
  should_have_many :taggings
  should_have_many :tags

  should "create tags successly" do
    topic = Topic.create(:title => "topic",:tag_list => "emacs;vim")
    #assert_equal Tag.count,2
  end
end
