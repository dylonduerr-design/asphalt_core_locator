class Sublot < ApplicationRecord
  belongs_to :lot, touch: true

  has_many :lanes, -> { order(:position) }, dependent: :destroy
  has_many :core_locations, dependent: :destroy

  validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }
end
