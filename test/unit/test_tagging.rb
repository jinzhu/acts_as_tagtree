require 'test/test_helper'

class TaggingTest < ActiveSupport::TestCase
  should "destroy useless tag when delete topic" do
    Tag.delete_all && Topic.delete_all
    topic = Topic.create(:title => 'title',:tag_list => 'linux>vim>plugin')
    assert_difference 'Tag.count',-3 do
      topic.destroy
    end
  end;

  should "doesn't destroy useful tag when delete topic" do
    Tag.delete_all && Topic.delete_all
    topic = Topic.create(:title => 'title',:tag_list => 'linux>vim>plugin')
    Topic.create(:title => 'title',:tag_list => 'linux>emacs>plugin')
    assert_difference 'Tag.count',-2 do
      topic.destroy
    end
  end

  should "destroy useless tag when change topic" do
    Tag.delete_all && Topic.delete_all
    topic = Topic.create(:title => 'title',:tag_list => 'linux>vim>plugin')
    assert_difference 'Tag.count',-1 do
      topic.update_attribute(:tag_list,'linux>emacs')
    end
  end
end
