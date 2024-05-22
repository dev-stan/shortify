class Source < ApplicationRecord
  # validates :url, format: { with: /\Ahttps?:\/\/[\w\d\-.]+\.[a-z]+\z/i,
  # message: 'must be a valid URL' }

  validates :url, format: { with: /\Ahttps:\/\/www.youtube.com\/.*/,
    message: 'Must be a valid YouTube URL ("https://www.youtube.com/...")' }

before_save :extract_youtube_id

  def extract_youtube_id
    self.youtube_id = url.match(/(?<=v=)([a-zA-Z0-9_-]+)/)[1]
  end



end
