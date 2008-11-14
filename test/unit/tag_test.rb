require 'test_helper'

class TagTest < ActiveSupport::TestCase

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


  context "Ignore old tags" do
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
end
