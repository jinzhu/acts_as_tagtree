require 'test/test_helper'

class TagListTest < ActiveSupport::TestCase

  should "create successful" do
    tags_list = [
    # ['',                      []], #blank
    # ['one',                   ["one"]],
    # ['  one ',                ["one"]],
    # ['one;two',               ["one","two"]],
    # ['one>two',               ["one>two"]],
    ['one>>two',              ["one>two"]],
    # ['"one space">two',       ["one space>two"]],
    # ['one space>two',         ["one space>two"]],
    # ['one space>two   ',      ["one space>two"]],
    # ['one space >   two',     ["one space>two"]],
    # ['one>"sp ace">two',      ["one>sp ace>two"]],
    # ['one>sp ace>two',        ["one>sp ace>two"]],
    # ['one>two;hello',         ["one>two",'hello']],
    ]
    tags_list.each do |tags,except|
      actual = TagList.format_tag(tags)
      assert_equal except,actual
    end
  end
end
