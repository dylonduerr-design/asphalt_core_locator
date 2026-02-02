class Lane < ApplicationRecord
  belongs_to :sublot, touch: true
  
  has_many :core_locations, dependent: :destroy
  has_many :left_lane_core_locations, class_name: "CoreLocation", foreign_key: :left_lane_id, dependent: :nullify
  has_many :right_lane_core_locations, class_name: "CoreLocation", foreign_key: :right_lane_id, dependent: :nullify

  validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :length_ft, presence: true, numericality: { greater_than: 0 }
  validates :width_ft, presence: true, numericality: { greater_than: 0 }
end
