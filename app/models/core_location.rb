class CoreLocation < ApplicationRecord
  belongs_to :core_generation
  belongs_to :lot
  belongs_to :sublot
  belongs_to :lane

  belongs_to :left_lane, class_name: "Lane", optional: true, foreign_key: :left_lane_id
  belongs_to :right_lane, class_name: "Lane", optional: true, foreign_key: :right_lane_id

  enum :core_type, { mat: 0, joint: 1 }

  validates :core_type, presence: true
  validates :linear_in_sublot_ft, :station_in_lane_ft, :offset_in_lane_ft, :distance_from_lot_start_ft,
            presence: true,
            numericality: true
end
