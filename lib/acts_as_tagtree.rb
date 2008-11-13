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
        end
      end
      
      module SingletonMethods
      end
      
      module InstanceMethods
      end
    end
  end
end

ActiveRecord::Base.send(:include, ActiveRecord::Acts::Tagtree)
