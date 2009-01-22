require 'acts_as_tree'

class Tag < ActiveRecord::Base
  has_many :taggings, :dependent => :destroy
  acts_as_tree

  validates_presence_of :name,:fullname
  validates_uniqueness_of :fullname

  alias_method :orig_destroy, :destroy
  attr_accessor :old_parent

  def before_update
    if fullname_changed?

      origin = Tag.find_by_fullname(self.fullname)
      if origin
        origin.children.map {|x| x.update_attribute(:parent_id,self.id)}
        origin.taggings.map {|x| x.update_attribute(:tag_id,self.id) }
        (@orphons_id ||= []) << origin.id
      end

      self.fullname   =~ /(.*)>(.*)$/
      self.name       =  $2
      self.old_parent =  self.parent
      self.parent     =  Tag.find_or_create_with_name($1)
    end
  end

  def after_update
    if fullname_changed?
      self.old_parent.destroy if self.old_parent

      # Change children's fullname
      self.children.map do |x|
        x.update_attribute(:fullname,fullname + '>' + x.name)
      end

      @orphons_id.map {|x| Tag.delete(x)} if @orphons_id   # Remove orphon tag
    end
  end

  def destroy
    # [self,self.parent,self.parent.parent...]
    [self].concat(self.ancestors).map { |x| x.deleteable? ? x.delete : break }
  end

  def deleteable?
    !(children? || taggings?)
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
    return ptag   # return the last find/create tag
  end

  def self.find_or_create_by_name_and_fullname(name,fullname)
    # doesn't case sensitive 
    tag = Tag.first(:conditions => ['fullname LIKE ?',fullname])    
    tag = Tag.create(:name => name,:fullname => fullname) unless tag
    return tag
  end

  def children?
    children.size > 0
  end

  def taggings?
    taggings.size > 0
  end

  def method_missing(m,*args)

    # tag1.all_articles find all tagged articles by tag1 and tag1's children
    #
    # SELECT * FROM articles,taggings WHERE tag_id IN (...) AND
    # taggable_id = articles.id AND taggable_type = 'Article'
    if m.to_s.match(/all_(\w+)/)
      return Tag.find_by_sql([" SELECT * FROM ?,taggings
                    WHERE taggings.tag_id IN (?)
                      AND taggable_id     =  ?.id
                      AND taggable_type   =  ?",
                      $1,
                      children_with_self.map(&:id).join(','),
                      $1,
                      $1.singularize.capitalize])
    end

    super
  end
end
