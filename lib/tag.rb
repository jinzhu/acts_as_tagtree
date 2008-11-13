class Tag < ActiveRecord::Base
  has_many :taggings, :dependent => :destroy
  
  def to_s
    name
  end
end
