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
        def cached_tag_list_column
          "cached_tag_list"
        end

        def set_cached_tag_list_column(value = nil, &block)
          define_attr_method :cached_tag_list_column_name, value, &block
        end

        def caching_tag_list?
          column_names.include?(cached_tag_list_column)
        end
      end
      
      module InstanceMethods

        def tag_list
          return @tag_list.join(';') if @tag_list
          if self.class.caching_tag_list?
            return self[self.class.cached_tag_list_column_name]
          else
            return tags.join(';')
          end
        end

        def tag_list=(value)
          @tag_list = TagList.format_tag(value)
          if self.class.caching_tag_list?
            self[self.class.cached_tag_list_column]= @tag_list.join(';')
          end
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

        def find_related(options={})
          key = options[:order] || self.class.primary_key
          num = options[:num] || 10

          result = []
          tags.each do |x|
            x.all_related.each do |x|
              x.taggings.each do |x|
                result << [x.taggable] if x.taggable.class == self.class
              end
            end
          end
          result= (result.flatten.uniq - [self]).sort {|x,y| x.send(key) <=> y.send(key)}
          result.reverse! if options[:reverse]
          return result[0...num]
        end
      end

    end
  end
end

ActiveRecord::Base.send(:include, ActiveRecord::Acts::Tagtree)
