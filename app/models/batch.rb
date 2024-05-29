class Batch < ApplicationRecord
  has_many :outputs
  belongs_to :source
end
