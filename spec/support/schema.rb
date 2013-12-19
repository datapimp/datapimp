require 'active_record'

ActiveRecord::Base.establish_connection(adapter:"sqlite3",database:":memory:")

ActiveRecord::Base.silence do
  ActiveRecord::Migration.verbose = false

  ActiveRecord::Schema.define do
    create_table :cached_models, :force => true do |t|
      t.string :name
      t.string :key1
      t.string :key2
      t.string :key3
      t.timestamps
    end

    create_table :projects, :force => true do |t|
      t.string :name
      t.timestamps
    end

    create_table :users, :force => true do |t|
      t.string :email
      t.string :name
      t.timestamps
    end

    create_table :people, :force => true do |t|
      t.string :name
      t.boolean :legit, :default => false
      t.integer :salary
      t.integer :parent_id
      t.timestamps
    end
  end
end
