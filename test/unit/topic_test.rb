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

  context "Find relative items" do
    setup do
      Tag.delete_all && Topic.delete_all
      @vim = Topic.create(:title => 'hello vim',:tag_list => 'linux>vim; editor>best')
      @vimrails = Topic.create(:title => 'rails.vim',:tag_list => 'linux>vim>plugin')
      @emacs = Topic.create(:title => 'emacs',:tag_list => 'linux>emacs; editor>best')
    end

    should "should find emacs use vim" do
      assert_equal @vim.find_related,[@vimrails,@emacs]
    end

    should "should find rails.vim use vim" do
    end
  end
end
