class ActsAsTagtreeMigration < ActiveRecord::Migration
  def self.up
    create_table :tags, :force => true do |t|
      t.string  :name
      t.string  :fullname
      t.integer :parent_id
    end

    create_table :taggings, :force => true do |t|
      t.column :tag_id, :integer
      t.column :taggable_id, :integer
      t.column :taggable_type, :string
      t.column :created_at, :datetime
    end

    add_index :tags,[:name, :fullname]
    add_index :tags,:name
    add_index :tags,:fullname
    add_index :tags,:parent_id

    add_index :taggings, :tag_id
    add_index :taggings, [:taggable_id, :taggable_type]
  end
  
  def self.down
    drop_table :tags
    drop_table :taggings
  end
end
