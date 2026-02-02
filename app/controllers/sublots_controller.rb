class SublotsController < ApplicationController
  before_action :set_sublot, only: %i[ show edit update destroy toggle_core_lock ]

  # GET /sublots or /sublots.json
  def index
    @sublots = Sublot.all
  end

  # GET /sublots/1 or /sublots/1.json
  def show
  end

  # GET /sublots/new
  def new
    @sublot = Sublot.new(sublot_params_for_new)
  end

  # GET /sublots/1/edit
  def edit
  end

  # POST /sublots or /sublots.json
  def create
    @sublot = Sublot.new(sublot_params)

    respond_to do |format|
      if @sublot.save
        format.html { redirect_to lot_path(@sublot.lot), notice: "Sublot was successfully created." }
        format.json { render :show, status: :created, location: @sublot }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @sublot.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sublots/1 or /sublots/1.json
  def update
    respond_to do |format|
      if @sublot.update(sublot_params)
        format.html { redirect_to @sublot, notice: "Sublot was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @sublot }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @sublot.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sublots/1 or /sublots/1.json
  def destroy
    @sublot.destroy!

    respond_to do |format|
      format.html { redirect_to sublots_path, notice: "Sublot was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  def toggle_core_lock
    @sublot.update!(locked_for_core_generation: !@sublot.locked_for_core_generation)
    redirect_back fallback_location: lot_path(@sublot.lot)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sublot
      @sublot = Sublot.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def sublot_params
      params.require(:sublot).permit(:lot_id, :position, :name)
    end

    def sublot_params_for_new
      params.fetch(:sublot, {}).permit(:lot_id, :position, :name)
    end
end
