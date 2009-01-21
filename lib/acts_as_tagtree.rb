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
          extend  ActiveRecord::Acts::Tagtree::SingletonMethods
          after_save :save_tags
        end
      end

      module SingletonMethods
        def cached_tag_list_column
          "cached_tag_list"
        end

        def set_cached_tag_list_column(value = nil, &block)
          define_attr_method :cached_tag_list_column, value, &block
        end

        def caching_tag_list?
          column_names.include?(cached_tag_list_column)
        end
      end

      module InstanceMethods

        def tag_list
          return @tag_list if @tag_list
          if self.class.caching_tag_list?
            TagList.format_tag(self[self.class.cached_tag_list_column_name])
          else
            tags
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
          num = options[:num] || [0,10]
          reverse = options[:reverse] ? "DESC" : "ASC" #TODO use cached_tag_list

          all_id = []
          tags.each do |x|
            x.all_related.each do |x|
              all_id.concat(x.taggings(:conditions => ['taggable_type IS ?',self.class]).map(&:taggable_id))
              end
            end
          id_range = (all_id - [self.id]).uniq.join(',')
          self.class.all(:conditions =>["id IN (#{id_range})"],:order => "#{key} #{reverse}",:limit => num.join(','))
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, ActiveRecord::Acts::Tagtree)
