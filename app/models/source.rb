class Source < ApplicationRecord
  belongs_to :user

  before_validation :extract_youtube_id

  def extract_youtube_id
    self.youtube_id = url.match(/(?<=v=)([a-zA-Z0-9_-]+)/)[1]
  end


end
