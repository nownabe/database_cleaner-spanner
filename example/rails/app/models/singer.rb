class Singer < ApplicationRecord
  has_many :albums, foreign_key: :singerid
  has_many :songs, foreign_key: :singerid
end
