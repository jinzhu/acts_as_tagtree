require 'test_helper'

class TagTest < ActiveSupport::TestCase

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
      assert_equal result,Tag.first(:conditions => ['fullname LIKE ?',x.sub(/^>/,'')])
      assert_equal Tag.count,num
    end
  end

  should "should keep uniq" do
    Tag.delete_all

    tag = 'linux>vim>plugin'
    Tag.find_or_create_with_name(tag)
    assert_equal Tag.count,3

    tag = 'linux>vim>plugin'
    Tag.find_or_create_with_name(tag)
    assert_equal Tag.count,3

    tag = 'vim>plugin>rails.vim'
    Tag.find_or_create_with_name(tag)
    assert_equal Tag.count,4

    tag = 'linux>emacs'
    Tag.find_or_create_with_name(tag)
    assert_equal Tag.count,5

    tag = 'linux>emacs>plugin'
    Tag.find_or_create_with_name(tag)
    assert_equal Tag.count,6

    tag = 'emacs>plugin>lisp.el'
    Tag.find_or_create_with_name(tag)
    assert_equal Tag.count,7

    tag = '>emacs>plugin>lisp.el'
    Tag.find_or_create_with_name(tag)
    assert_equal Tag.count,10

    tag = '>linux>vim'
    Tag.find_or_create_with_name(tag)
    assert_equal Tag.count,10
  end
end
