class BulkSetupsController < ApplicationController
  def new
    @lot = Lot.find(params[:lot_id])
    @num_sublots = params[:num_sublots]&.to_i || 1
    @lanes_per_sublot = params[:lanes_per_sublot]&.to_i || 1
    @starting_position = (@lot.sublots.maximum(:position) || 0) + 1
  end

  def create
    @lot = Lot.find(params[:lot_id])
    
    Rails.logger.debug "Params received: #{params.inspect}"
    
    if params[:sublots].blank?
      redirect_to lot_path(@lot), alert: "No sublot data provided"
      return
    end
    
    starting_position = (@lot.sublots.maximum(:position) || 0)
    
    Lot.transaction do
      params[:sublots].each do |idx, sublot_data|
        sublot = @lot.sublots.create!(
          position: starting_position + idx.to_i + 1,
          name: "Sublot #{starting_position + idx.to_i + 1}"
        )
        
        next if sublot_data[:lanes].blank?
        
        sublot_data[:lanes].each do |lane_idx, lane_data|
          next if lane_data[:length_ft].blank?
          
          sublot.lanes.create!(
            position: lane_idx.to_i + 1,
            name: "Lane #{lane_idx.to_i + 1}",
            length_ft: lane_data[:length_ft],
            width_ft: lane_data[:width_ft]
          )
        end
      end
    end
    
    redirect_to lot_path(@lot), notice: "Sublots and lanes created successfully"
  rescue ActiveRecord::RecordInvalid => e
    flash[:alert] = "Error: #{e.message}"
    redirect_to new_lot_bulk_setup_path(@lot)
  end
end
