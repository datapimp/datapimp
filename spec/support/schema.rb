require 'active_record'

ActiveRecord::Base.establish_connection(adapter:"sqlite3",database:":memory:")

ActiveRecord::Base.silence do
  ActiveRecord::Migration.verbose = false

  ActiveRecord::Schema.define do
    create_table :projects, :force => true do |t|
      t.string :name
    end

    create_table :users, :force => true do |t|
      t.string :email
      t.string :name
    end

    create_table :people, :force => true do |t|
      t.string :name
      t.boolean :legit, :default => false
      t.integer :salary
      t.integer :parent_id
    end
  end
end
