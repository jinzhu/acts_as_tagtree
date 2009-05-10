require 'test/test_helper'

class ArticleTest < ActiveSupport::TestCase

  should "cached_tag_list?" do
    assert !Article.caching_tag_list?
  end

  should "cached tag_list successly" do
    art = Article.create(:title => "t",:tag_list => 'linux>vim> plugin ;ruby>rails')
    assert_equal art.reload.tag_list,['linux>vim>plugin','ruby>rails']
  end

  should "cached tag_list" do
    Tag.delete_all
    Tag.find_or_create_with_name('linux>vim>plugin')
    art = Article.create(:title => "t",:tag_list => 'vim>plugin;')
    assert_equal art.reload.tag_list,['linux>vim>plugin']
  end
end
