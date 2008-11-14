module ActiveRecord #:nodoc:
  module Acts #:nodoc:
    module Tagtree #:nodoc:
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        def acts_as_tagtree
          has_many :taggings,:as => :taggable,:dependent => :destroy,:include => :tag
          has_many :tags,:through => :taggings
          include ActiveRecord::Acts::Tagtree::InstanceMethods
          extend ActiveRecord::Acts::Tagtree::SingletonMethods
          after_save :save_tags
        end
      end
      
      module SingletonMethods
      end
      
      module InstanceMethods

        def tag_list=(value)
          @tag_list = TagList.format_tag(value)
        end

        def save_tags
          new_tags_name = @tag_list - tags.map(&:fullname)
          outdate_tags = tags.reject {|tag| @tag_list.include?(tag.fullname)}
          self.class.transaction do
            if outdate_tags.any?
              taggings.find(:all,:conditions => ["tag_id IN (?)",outdate_tags.map(&:id)]).each(&:destroy)
            end
            new_tags_name.each do |name|
              tags << Tag.find_or_create_with_name(name)
            end
          end
        end

        def find_related
          result = []
          tags.each do |x|
            x.all_related.each do |x|
              x.taggings.each do |x| #send(self.class.table_name)
                result << [x.taggable] if x.taggable.class == self.class
              end
            end
          end
          return (result.flatten.uniq - [self])
        end
      end

    end
  end
end

ActiveRecord::Base.send(:include, ActiveRecord::Acts::Tagtree)
