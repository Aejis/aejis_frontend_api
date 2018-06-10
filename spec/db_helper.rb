require 'sequel'

DB = Sequel.sqlite

DB.create_table :users do
  primary_key :id
  column :name, String, null: false
  column :image, String
  column :image_urls, :jsonb, null: false, default: '{}'
  column :position, Integer, default: 1
end
