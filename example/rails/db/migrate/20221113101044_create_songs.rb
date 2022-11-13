class CreateSongs < ActiveRecord::Migration[7.0]
  def change
    create_table :songs, id: false do |t|
      t.interleave_in :albums
      t.primary_key :songid
      t.parent_key :singerid
      t.parent_key :albumid
      t.string :title, null: false

      t.timestamps
    end
  end
end
