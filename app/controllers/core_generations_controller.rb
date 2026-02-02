require "csv"

class CoreGenerationsController < ApplicationController
  before_action :set_lot

  def new
    @core_generation = @lot.core_generations.build
  end

  def create
    @core_generation = @lot.core_generations.build(core_generation_params)

    if @core_generation.save
      begin
        latest = latest_generation(exclude_id: @core_generation.id)
        locked_ids = @lot.sublots.where(locked_for_core_generation: true).pluck(:id)

        CoreGenerator.new(@core_generation, locked_sublot_ids: locked_ids).generate!

        if latest && locked_ids.any?
          copy_core_locations(latest, @core_generation, locked_ids)
        end
        redirect_to lot_core_generation_path(@lot, @core_generation), notice: "Core locations generated successfully"
      rescue StandardError => e
        @core_generation.destroy
        flash.now[:alert] = "Generation failed: #{e.message}"
        render :new, status: :unprocessable_entity
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def create_for_sublot
    @sublot = @lot.sublots.find(params[:sublot_id])

    if @sublot.locked_for_core_generation
      redirect_back fallback_location: lot_path(@lot), alert: "Sublot #{@sublot.position} is locked and cannot be regenerated"
      return
    end

    @core_generation = @lot.core_generations.build(generation_defaults_from_latest)

    if @core_generation.save
      begin
        latest = latest_generation(exclude_id: @core_generation.id)
        CoreGenerator.new(@core_generation, target_sublot_ids: [@sublot.id]).generate!

        if latest
          other_ids = @lot.sublots.where.not(id: @sublot.id).pluck(:id)
          copy_core_locations(latest, @core_generation, other_ids) if other_ids.any?
        end

        redirect_to lot_core_generation_path(@lot, @core_generation), notice: "Core locations generated for Sublot #{@sublot.position}"
      rescue StandardError => e
        @core_generation.destroy
        flash[:alert] = "Generation failed: #{e.message}"
        redirect_back fallback_location: lot_path(@lot)
      end
    else
      redirect_back fallback_location: lot_path(@lot), alert: @core_generation.errors.full_messages.to_sentence
    end
  end

  def show
    @core_generation = @lot.core_generations.includes(core_locations: [:lane, :sublot]).find(params[:id])
    @sort_by_sublot = params[:sort] == 'sublot'
    
    if @sort_by_sublot
      @core_locations = @core_generation.core_locations.order(:sublot_id, :core_type, :mark)
    else
      @core_locations = @core_generation.core_locations.order(:core_type, :sublot_id, :mark)
    end
  end

  def export_csv
    @core_generation = @lot.core_generations.includes(core_locations: [:lane, :sublot]).find(params[:id])

    csv = CSV.generate do |out|
      out << ["Mark", "Type", "Sublot", "Lane", "Left Lane", "Right Lane", "Lot Dist (ft)", "Sublot Linear (ft)", "Station in Lane (ft)", "Offset in Lane (ft)"]
      @core_generation.core_locations.order(:mark).find_each do |loc|
        out << [
          loc.mark,
          loc.core_type,
          loc.sublot.position,
          loc.lane_index,
          loc.left_lane_id,
          loc.right_lane_id,
          loc.distance_from_lot_start_ft,
          loc.linear_in_sublot_ft,
          loc.station_in_lane_ft,
          loc.offset_in_lane_ft
        ]
      end
    end

    send_data csv,
              filename: "lot-#{@lot.lot_number}-core-locations-#{@core_generation.id}.csv",
              type: "text/csv"
  end

  private

  def set_lot
    @lot = Lot.find(params[:lot_id])
  end

  def core_generation_params
    params.require(:core_generation).permit(
      :seed,
      :rounding_increment_ft,
      :mat_edge_buffer_ft,
      :lane_start_buffer_ft,
      :mat_cores_per_sublot,
      :joint_cores_per_joint
    )
  end

  def latest_generation(exclude_id: nil)
    scope = @lot.core_generations.order(created_at: :desc)
    scope = scope.where.not(id: exclude_id) if exclude_id
    scope.first
  end

  def generation_defaults_from_latest
    latest = latest_generation
    return {} unless latest

    {
      rounding_increment_ft: latest.rounding_increment_ft,
      mat_edge_buffer_ft: latest.mat_edge_buffer_ft,
      lane_start_buffer_ft: latest.lane_start_buffer_ft,
      mat_cores_per_sublot: latest.mat_cores_per_sublot,
      joint_cores_per_joint: latest.joint_cores_per_joint
    }
  end

  def copy_core_locations(from_generation, to_generation, sublot_ids)
    return if from_generation.nil? || sublot_ids.empty?

    from_generation.core_locations.where(sublot_id: sublot_ids).find_each do |loc|
      CoreLocation.create!(
        core_generation: to_generation,
        lot: loc.lot,
        sublot: loc.sublot,
        lane: loc.lane,
        left_lane: loc.left_lane,
        right_lane: loc.right_lane,
        core_type: loc.core_type,
        lane_index: loc.lane_index,
        linear_in_sublot_ft: loc.linear_in_sublot_ft,
        station_in_lane_ft: loc.station_in_lane_ft,
        offset_in_lane_ft: loc.offset_in_lane_ft,
        distance_from_lot_start_ft: loc.distance_from_lot_start_ft,
        mark: loc.mark
      )
    end
  end
end
