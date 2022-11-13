class CreateAlbums < ActiveRecord::Migration[7.0]
  def change
    create_table :albums, id: false do |t|
      t.interleave_in :singers
      t.primary_key :albumid
      t.parent_key :singerid
      t.string :title, null: false

      t.timestamps
    end
  end
end
