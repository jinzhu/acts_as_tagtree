require 'test/test_helper'

class ArticleTest < ActiveSupport::TestCase

  should "cached_tag_list?" do
    assert !Article.caching_tag_list?
  end

  should "cache tag_list successly" do
    art = Article.create(:title => "t",:tag_list => 'linux>vim> plugin ;ruby>rails')
    assert_equal art.reload.tag_list,['linux>vim>plugin','ruby>rails']
  end
end
