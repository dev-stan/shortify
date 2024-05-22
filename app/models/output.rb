class Output < ApplicationRecord
  belongs_to :user
  belongs_to :source

  FONTFAMILIES = ["Font1", "Font2", "Font3"]
  validates :font_family, presence: true, inclusion: { in: FONTFAMILIES }
  FONTSTYLES = ["Normal", "Italic", "Bold"]
  validates :font_style, presence: true, inclusion: { in: FONTSTYLES }
  validates :script, presence: true

  VIDEOS = ["vid1", "vid2", "vid3", "vid4"]
end
