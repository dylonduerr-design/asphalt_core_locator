# frozen_string_literal: true

class CoreGenerationRunner
  class GenerationError < StandardError; end

  def initialize(core_generation)
    @core_generation = core_generation
  end

  def run!
    raise GenerationError, "Core generation is invalid" unless @core_generation.valid?

    lot = @core_generation.lot
    rng = Random.new(Integer(@core_generation.seed))

    rounding = @core_generation.rounding_increment_ft.to_d
    edge_buffer = @core_generation.mat_edge_buffer_ft.to_d
    lane_start_buffer = @core_generation.lane_start_buffer_ft.to_d

    mat_per_sublot = @core_generation.mat_cores_per_sublot
    joint_per_joint = @core_generation.joint_cores_per_joint

    lot_mat_offset = 0.to_d
    lot_joint_offset = 0.to_d

    mat_seq = 0
    joint_seq = 0

    CoreGeneration.transaction do
      @core_generation.core_locations.delete_all

      lot.sublots.order(:position).includes(:lanes).each do |sublot|
        lanes = sublot.lanes.order(:position).to_a
        raise GenerationError, "Sublot #{sublot.position} has no lanes" if lanes.empty?

        sublot_mat_total = lanes.sum { |ln| ln.length_ft.to_d }

        # Mat cores: pick a lane weighted by its *usable* length.
        mat_per_sublot.times do
          lane, station_in_lane = pick_lane_and_station(rng:, lanes:, lane_start_buffer:, rounding:)
          offset_in_lane = pick_offset(rng:, lane:, edge_buffer:, rounding:)

          lane_index = lane.position
          linear_in_sublot = lane_prefix_length(lanes, lane_index) + station_in_lane
          distance_from_lot_start = lot_mat_offset + linear_in_sublot

          mat_seq += 1
          @core_generation.core_locations.create!(
            lot: lot,
            sublot: sublot,
            core_type: :mat,
            lane: lane,
            lane_index: lane_index,
            linear_in_sublot_ft: linear_in_sublot,
            station_in_lane_ft: station_in_lane,
            offset_in_lane_ft: offset_in_lane,
            distance_from_lot_start_ft: distance_from_lot_start,
            mark: "M #{lot.lot_number}-#{mat_seq}"
          )
        end

        # Joint cores: joints are between adjacent lanes (1-2, 2-3, ...)
        joint_segments = lanes.each_cons(2).map do |left, right|
          overlap = [left.length_ft.to_d, right.length_ft.to_d].min
          { left:, right:, length: overlap }
        end.select { |seg| seg[:length] > 0 }

        sublot_joint_total = joint_segments.sum { |seg| seg[:length] }

        joint_segments.each_with_index do |seg, idx|
          next if joint_per_joint <= 0

          left = seg[:left]
          right = seg[:right]
          joint_length = seg[:length]

          usable_max = joint_length
          usable_min = lane_start_buffer
          next if usable_max < usable_min

          joint_per_joint.times do
            station_in_joint = pick_from_grid(rng:, min: usable_min, max: usable_max, step: rounding)

            # "Linear" for joints is the concatenation of joint lengths within the sublot.
            linear_in_sublot_joint = joint_prefix_length(joint_segments, idx) + station_in_joint
            distance_from_lot_start_joint = lot_joint_offset + linear_in_sublot_joint

            joint_seq += 1
            @core_generation.core_locations.create!(
              lot: lot,
              sublot: sublot,
              core_type: :joint,
              lane: left,
              left_lane_id: left.id,
              right_lane_id: right.id,
              lane_index: left.position,
              linear_in_sublot_ft: linear_in_sublot_joint,
              station_in_lane_ft: station_in_joint,
              # Offset is reported relative to the left lane; at the joint line this is the full lane width.
              offset_in_lane_ft: left.width_ft.to_d,
              distance_from_lot_start_ft: distance_from_lot_start_joint,
              mark: "J #{lot.lot_number}-#{joint_seq}"
            )
          end
        end

        lot_mat_offset += sublot_mat_total
        lot_joint_offset += sublot_joint_total
      end
    end

    @core_generation
  end

  private

  def pick_lane_and_station(rng:, lanes:, lane_start_buffer:, rounding:)
    usable = lanes.map do |lane|
      length = lane.length_ft.to_d
      usable_len = length - lane_start_buffer
      { lane:, length:, usable_len: usable_len.positive? ? usable_len : 0.to_d }
    end

    total = usable.sum { |h| h[:usable_len] }
    raise GenerationError, "No lane has usable length after the 10ft start buffer" if total <= 0

    target = rng.rand * total.to_f
    running = 0.0

    chosen = usable.find do |h|
      running += h[:usable_len].to_f
      running >= target
    end || usable.last

    lane = chosen[:lane]
    min_station = lane_start_buffer
    max_station = chosen[:length]
    station = pick_from_grid(rng:, min: min_station, max: max_station, step: rounding)

    [lane, station]
  end

  def pick_offset(rng:, lane:, edge_buffer:, rounding:)
    width = lane.width_ft.to_d
    min_offset = edge_buffer
    max_offset = width - edge_buffer

    raise GenerationError, "Lane #{lane.position} width too small for 1ft edge buffers" if max_offset < min_offset

    pick_from_grid(rng:, min: min_offset, max: max_offset, step: rounding)
  end

  def pick_from_grid(rng:, min:, max:, step:)
    step_f = step.to_d
    min_i = (min / step_f).ceil
    max_i = (max / step_f).floor

    raise GenerationError, "No valid points on rounding grid" if max_i < min_i

    k = rng.rand(min_i..max_i)
    (step_f * k).to_d
  end

  def lane_prefix_length(lanes, lane_position)
    lanes.select { |ln| ln.position < lane_position }.sum { |ln| ln.length_ft.to_d }
  end

  def joint_prefix_length(joint_segments, joint_index)
    joint_segments.take(joint_index).sum { |seg| seg[:length] }
  end
end
