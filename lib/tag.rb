require 'acts_as_tree'
class Tag < ActiveRecord::Base
  has_many :taggings, :dependent => :destroy
  acts_as_tree

  validates_presence_of :name,:fullname
  validates_uniqueness_of :fullname

  alias_method :orig_destroy, :destroy
  def destroy
    ancestors_with_self = [self].concat(self.ancestors)
    ancestors_with_self.each do |x|
      (x.children? || x.taggings?) ? break : x.delete
    end
  end

  def to_s
    fullname
  end

  def self.find_or_create_with_name(name)
    tags = name.split('>')

    unless tags[0].empty?
      # find the parent tag if exist tags[0]
      ptag = Tag.first(:conditions => ['name LIKE ? ',tags[0]])
      # '[linux,vim]' if havn't find linux then tags became ['',linux,vim]
      tags[0,0]= '' unless ptag
    else
      ptag = nil
    end

    tags[1...tags.size].each do |x|
      if ptag
        # if exist parent tag then find or create child tag
        ptag = ptag.children.find_or_create_by_name_and_fullname(x,ptag.fullname+'>'+x)
      else
        # if doesn't exist parent tag then find or create then parent tag
        ptag = Tag.find_or_create_by_name_and_fullname(x,x)
      end
    end
    return ptag
  end

  def self.find_or_create_by_name_and_fullname(name,fullname)
    # doesn't case sensitive 
    tag = Tag.first(:conditions => ['fullname LIKE ?',fullname])    
    tag = Tag.create(:name => name,:fullname => fullname) unless tag
    return tag
  end

  def children?
    children_without_self.size > 0
  end

  def taggings?
    taggings.size > 0
  end
end
