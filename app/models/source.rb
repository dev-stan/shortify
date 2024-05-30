class Source < ApplicationRecord
  # validates :url, format: { with: /\Ahttps?:\/\/[\w\d\-.]+\.[a-z]+\z/i,
  # message: 'must be a valid URL' }
  has_one_attached :video
  has_many :batches

end
