require 'test_helper'

class TopicTest < ActiveSupport::TestCase
  should_have_db_columns :title
  should_have_many :taggings
  should_have_many :tags

  tag_lists = [
    ['emacs;vim',2],
    ['bsd;linux;mac',3],
    ['linux>vim>plugin;emacs',4],
    ['linux>vim>plugin;emacs>plugin',5],
    ['linux>vim>plugin;linux>gentoo',4],
    ['linux>vim>plugin;Linux>gentoo',4],
  ]

  tag_lists.each do |tag,num|
    should "\"#{tag}\" should create #{num} tags" do
      Tag.delete_all && Topic.delete_all
      topic = Topic.create(:title => "topic",:tag_list => tag)
      assert_equal Tag.count,num
    end
  end
end
