require 'test/test_helper'

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

  context "test find related items" do
      setup do
        Tag.delete_all && Topic.delete_all
        @vim = Topic.create(:title => 'hello vim',:tag_list => 'linux>vim; editor>best')
        @vimrails = Topic.create(:title => 'rails.vim',:tag_list => 'linux>vim>plugin')
        @emacs = Topic.create(:title => 'emacs',:tag_list => 'linux>emacs; editor>best')
        @unrelated = Topic.create(:title => 'unrelated')
      end

      should "should find emacs use vim" do
        assert_equal @vim.find_related,[@vimrails,@emacs]
      end

      should "should correct if have no related item" do
        assert_equal @unrelated.find_related,[]
      end

      should "test reverse" do
        assert_equal @vim.find_related({:reverse => true}),[@emacs,@vimrails]
      end

      should "test order" do
        assert_equal @vim.find_related({:order => "title"}),[@emacs,@vimrails]
      end

      should "test related's quantity" do
        assert_equal @vim.find_related(:num => [0,1]).size,1
        assert_equal @vim.find_related(:num => [0,2]).size,2
        assert_equal @vim.find_related(:num => [0,3]).size,2 #out of range
      end

      should "should find vim use rails.vim" do
        assert_equal @vimrails.find_related,[@vim]
      end
  end

  should "cached_tag_list?" do
    assert Topic.caching_tag_list?
  end

  should "cache tag_list successly" do
    topic = Topic.create(:title => "topic",:tag_list => 'linux>vim> plugin ;ruby>rails')
    assert_equal topic.cached_tag_list,'linux>vim>plugin;ruby>rails'
    assert_equal topic.reload.tag_list,['linux>vim>plugin','ruby>rails']
  end
end
