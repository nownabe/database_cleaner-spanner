class Album < ApplicationRecord
  self.primary_keys = :singerid, :albumid
  belongs_to :singer, foreign_key: :singerid
  has_many :songs, foreign_key: [:singerid, :albumid]
end
