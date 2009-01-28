require 'test/test_helper'

class TagTest < ActiveSupport::TestCase
  should_require_attributes :name,:fullname
  should_require_unique_attributes :fullname

  context "When create single tag from scratch" do
    tags = [
      ['linux',1],
      ['linux>vim',2],
      ['linux>vim>plugin',3],
      ['>linux>vim>plugin',3],
      ['linux>vim>plugin>a>b>c>d',7],
    ]
    tags.each do |x,num|
      should "\"#{x}\" should create #{num} tags and return the last tag" do
        Tag.delete_all
        result = Tag.find_or_create_with_name(x)
        assert_equal Tag.count,num
      end
    end

    tags.each do |x,num|
      should "\"#{x}\" should return the last tag" do
        Tag.delete_all
        result = Tag.find_or_create_with_name(x)
        assert_equal result,Tag.first(:conditions => ['fullname LIKE ?',x.sub(/^>/,'')])
      end
    end
  end


  context "When create tag from old tags" do
    setup do
      Tag.delete_all
      assert_difference 'Tag.count',3 do
        tag = 'linux>vim>plugin'
        Tag.find_or_create_with_name(tag)
      end
    end

    should "not create tags when only use old tags" do
      assert_difference 'Tag.count',0 do
        tag = 'linux>vim>plugin'
        Tag.find_or_create_with_name(tag)
      end
      assert_difference 'Tag.count',0 do
        tag = 'linux>Vim>Plugin'
        Tag.find_or_create_with_name(tag)
      end
    end

    should "use old tags when add new tags" do
      assert_difference 'Tag.count',1 do
        tag = 'vim>plugin>rails.vim'
        Tag.find_or_create_with_name(tag)
      end

      assert_difference 'Tag.count',0 do
        tag = 'vim>plugin>raIls.Vim'
        Tag.find_or_create_with_name(tag)
      end

      assert_difference 'Tag.count',1 do
        tag = 'linux>emacs'
        Tag.find_or_create_with_name(tag)
      end

      assert_difference 'Tag.count',1 do
        tag = 'Linux>emacs>plugin'
        Tag.find_or_create_with_name(tag)
      end
    end

    should "Create New tag or use the root tag when use >.." do
      assert_difference 'Tag.count',2 do
        tag = '>vim>plugin'
        Tag.find_or_create_with_name(tag)
      end
    end
  end

  should "self_and_children should be correct" do
    Tag.delete_all
    tag = 'linux>emacs>plugin'
    Tag.find_or_create_with_name(tag)
    linux = Tag.find_by_name('linux')
    assert_equal linux.children_without_self.size,2
    assert_equal linux.children_with_self.size,3
  end

  should "all_related should be correct" do
    Tag.delete_all
    Tag.find_or_create_with_name('linux>emacs>plugin')
    Tag.find_or_create_with_name('linux>vim>plugin')
    Tag.find_or_create_with_name('vim>plugin>rails.vim')
    Tag.find_or_create_with_name('os>linux>vim')
    linuxvim = Tag.find_by_fullname('linux>vim')
    assert_equal linuxvim.all_related.size,4
    linuxemacs = Tag.find_by_fullname('linux>emacs')
    assert_equal linuxemacs.all_related.size,3
  end

  should "children?" do
    Tag.delete_all
    last_tag = Tag.find_or_create_with_name('linux>emacs>plugin')
    assert !last_tag.children?
    assert Tag.find_by_name('linux').children?
  end

  should "taggings?" do
    Tag.delete_all && Topic.delete_all
    Topic.create(:title => 'title',:tag_list => 'linux>vim>plugin')
    Tag.find_or_create_with_name('linux>emacs>plugin')
    assert Tag.find_by_fullname('linux>vim>plugin').taggings?
    assert !Tag.find_by_name('emacs').taggings?
  end

  should "should destroy all useless ancestors" do
    Tag.delete_all
    Tag.find_or_create_with_name('linux>emacs>plugin>rails.el')
    assert_difference 'Tag.count',-4 do
      Tag.find_by_name("rails.el").destroy
    end
  end

  should "shouldn't destroy helpful ancestors" do
    Tag.delete_all
    Tag.find_or_create_with_name('linux>emacs>plugin>rails.el')
    Tag.find_or_create_with_name('linux>emacs>plugin>perl.el')
    assert_difference 'Tag.count',-1 do
      Tag.find_by_name("rails.el").destroy
    end
  end

  #
  # Update Tag
  #
  context "When Update No Exist Fullname" do
    setup do
      Tag.delete_all
      @tag = Tag.find_or_create_with_name('linux>emacs>plugin')
      Tag.find_or_create_with_name('linux>emacs>plugin>rails')
    end

    should "create new parent,destroy old useless parent" do
      @tag.update_attribute(:fullname,'linux>vim>plugin')
      assert_equal Tag.find_all_by_name('emacs').size,0
      assert_equal Tag.find_all_by_name('vim').size,1
      assert_equal Tag.count,4
    end

    should "not destroy usefull parent" do
      Tag.find_or_create_with_name('linux>emacs>tips')
      assert_equal Tag.count,5
      @tag.update_attribute(:fullname,'linux>vim>plugin')
      assert_equal Tag.count,6
    end

    should "change children's fullname" do
      @tag.update_attribute(:fullname,'linux>vim>plugin')
      assert_equal Tag.find_by_name('rails').to_s,"linux>vim>plugin>rails"
    end
  end

  context "When Update Exist Fullname" do
    setup do
      Tag.delete_all
      @tag = Tag.find_or_create_with_name('linux>emacs>plugin')
      Tag.find_or_create_with_name('linux>emacs>plugin>rails')
      Tag.find_or_create_with_name('linux>vim>plugin')
      @tag.update_attribute(:fullname,'linux>vim>plugin')
      assert_equal Tag.count,4
    end

    should "use existed parent,destroy old useless parent" do
      assert_equal Tag.find_all_by_name('emacs').size,0
      assert_equal Tag.find_all_by_name('vim').size,1
    end

    should "change children's fullname" do
      assert_equal Tag.find_by_name('rails').to_s,"linux>vim>plugin>rails"
      assert_equal Tag.find_by_name('rails').to_s,"linux>vim>plugin>rails"
    end
  end

  context "complex update" do
    setup do
      Tag.delete_all
      @tag = Tag.find_or_create_with_name('linux>emacs>plugin')
      Tag.find_or_create_with_name('linux>emacs>plugin>rails')
      Tag.find_or_create_with_name('linux>emacs>plugin>rails>A')
      Tag.find_or_create_with_name('linux>emacs>plugin>rails>B')
      Tag.find_or_create_with_name('linux>emacs>plugin>merb>A')
      Tag.find_or_create_with_name('linux>emacs>plugin>merb>B')
      Tag.find_or_create_with_name('linux>vim>plugin')
      Tag.find_or_create_with_name('linux>vim>plugin>rails')
      Tag.find_or_create_with_name('linux>vim>plugin>rails>A')
      Tag.find_or_create_with_name('linux>vim>plugin>rails>C')
    end

    should "Catch origin tag's children" do
      @tag.update_attribute(:fullname,'linux>vim>plugin')
      assert_equal Tag.find_all_by_fullname("linux>vim>plugin").size,1
      assert_equal Tag.find_all_by_fullname("linux>vim>plugin>rails").size,1
      assert_equal Tag.find_all_by_fullname("linux>vim>plugin>rails>A").size,1
      assert_equal Tag.find_by_fullname("linux>vim>plugin>rails").children.size,3
      assert_equal Tag.find_by_fullname("linux>vim>plugin>rails>C").parent.to_s,"linux>vim>plugin>rails"
    end

    should "Catch origin tag's taggings" do
      Tagging.delete_all
      topic   = Topic.create(:title => 'title',:tag_list => 'linux>vim>plugin')
      vim_a   = Topic.create(:title => 'title',:tag_list => 'linux>vim>plugin>rails>A')
      emacs_a = Tag.find_or_create_with_name('linux>emacs>plugin>rails>A')

      @tag.update_attribute(:fullname,'linux>vim>plugin')

      assert_equal vim_a.taggings.first.tag_id,emacs_a.id   #origin tag's children's taggings
      assert_equal Tagging.first.tag_id,@tag.id
    end
  end

  should "method_missing all_***" do
    Tag.delete_all && Tagging.delete_all
    tag = Tag.find_or_create_with_name('linux')
    topic = Topic.create(:title => 't1',:tag_list => 'linux')
    topic = Topic.create(:title => 't2',:tag_list => 'linux')
    topic = Topic.create(:title => 't3',:tag_list => 'linux')
    assert_equal tag.all_topics.size,3
    assert_equal tag.all_topics.first.class,Topic
  end
end
