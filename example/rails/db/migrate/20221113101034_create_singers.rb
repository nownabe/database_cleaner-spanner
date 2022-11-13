class CreateSingers < ActiveRecord::Migration[7.0]
  def change
    create_table :singers, id: false do |t|
      t.primary_key :singerid
      t.string :name, null: false

      t.timestamps
    end
  end
end
