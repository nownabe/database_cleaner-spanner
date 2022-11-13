class Song < ApplicationRecord
  self.primary_keys = :singerid, :albumid, :songid
  belongs_to :album, foreign_key: [:singerid, :albumid]
  belongs_to :singer, foreign_key: :singerid

  def initialize(attributes = nil)
    super
    self.singer ||= album&.singer
  end

  def album=(album)
    super
    self.singer = album&.singer
  end
end
