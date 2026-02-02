class LanesController < ApplicationController
  before_action :set_lane, only: %i[ show edit update destroy ]

  # GET /lanes or /lanes.json
  def index
    @lanes = Lane.all
  end

  # GET /lanes/1 or /lanes/1.json
  def show
  end

  # GET /lanes/new
  def new
    @lane = Lane.new(lane_params_for_new)

    if @lane.sublot_id.present?
      @sublot = Sublot.includes(:lot).find_by(id: @lane.sublot_id)

      if @sublot
        @next_position = (@sublot.lanes.maximum(:position) || 0) + 1
        @lane.position ||= @next_position
        @lane.name ||= "Lane #{@next_position}"
      end
    end
  end

  # GET /lanes/1/edit
  def edit
  end

  # POST /lanes or /lanes.json
  def create
    @lane = Lane.new(lane_params)
    
    # Auto-assign position and name if not provided
    if @lane.sublot_id.present?
      sublot = Sublot.find(@lane.sublot_id)
      next_position = (sublot.lanes.maximum(:position) || 0) + 1
      @lane.position ||= next_position
      @lane.name ||= "Lane #{next_position}"
    end

    respond_to do |format|
      if @lane.save
        format.html { redirect_to lot_path(@lane.sublot.lot), notice: "Lane was successfully added." }
        format.json { render :show, status: :created, location: @lane }
      else
        format.html { redirect_to lot_path(@lane.sublot.lot), alert: "Error adding lane: #{@lane.errors.full_messages.join(', ')}" }
        format.json { render json: @lane.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lanes/1 or /lanes/1.json
  def update
    respond_to do |format|
      if @lane.update(lane_params)
        format.html { redirect_to @lane, notice: "Lane was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @lane }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @lane.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lanes/1 or /lanes/1.json
  def destroy
    lot = @lane.sublot.lot
    @lane.destroy!

    respond_to do |format|
      format.html { redirect_to lot_path(lot), notice: "Lane was successfully removed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lane
      @lane = Lane.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def lane_params
      params.require(:lane).permit(:sublot_id, :length_ft, :width_ft)
    end

    def lane_params_for_new
      params.fetch(:lane, {}).permit(:sublot_id, :length_ft, :width_ft)
    end
end
