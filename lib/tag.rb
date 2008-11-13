require 'acts_as_tree'
class Tag < ActiveRecord::Base
  has_many :taggings, :dependent => :destroy
  acts_as_tree

  def to_s
    name
  end

  def self.find_or_create_with_name(name)
    tags = name.split('>')
    return find_treetag(tags)
  end

  def self.find_treetag(tags)
    return create_treetag(tags[1...tags.size]) if tags[0].blank?

    ptag = []
    (0...tags.size).each do |x|
      unless ptag.blank?
        ptag << ptag[x-1].children.first(:conditions => ['name LIKE ? ',tags[x]])
      else
        ptag << Tag.first(:conditions => ['name LIKE ? ',tags[x]])
      end
      ((ptag << create_treetag(tags[x...tags.size],ptag[x-1])) && break) unless ptag[x]
    end
    return ptag.last
  end

  def self.create_treetag(tags, ptag=nil)
    tags.each do |x|    
      unless ptag.blank?
        ptag = ptag.children.find_or_create_by_name_and_fullname(x,ptag.fullname+'>'+x)
      else
        ptag = Tag.find_or_create_by_name_and_fullname(x,x)
      end
    end
    return ptag
  end
end
