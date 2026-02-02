class LotsController < ApplicationController
  before_action :set_lot, only: %i[ show edit update destroy ]

  # GET /lots or /lots.json
  def index
    @current_lot = Lot.order(updated_at: :desc).first
  end

  # GET /lots/all
  def all_lots
    @lots = Lot.all
    @lots = @lots.for_plant(params[:plant]) if params[:plant].present?
    @lots = @lots.for_mix(params[:mix_type]) if params[:mix_type].present?
    @lots = @lots.order(updated_at: :desc)
    
    @selected_plant = params[:plant]
    @selected_mix = params[:mix_type]
    render :all_lots
  end

  # GET /lots/1 or /lots/1.json
  def show
  end

  # GET /lots/new
  def new
    @lot = Lot.new
  end

  # GET /lots/1/edit
  def edit
  end

  # POST /lots or /lots.json
  def create
    @lot = Lot.new(lot_params)

    respond_to do |format|
      if @lot.save
        format.html { redirect_to @lot, notice: "Lot was successfully created." }
        format.json { render :show, status: :created, location: @lot }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @lot.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lots/1 or /lots/1.json
  def update
    respond_to do |format|
      if @lot.update(lot_params)
        format.html { redirect_to @lot, notice: "Lot was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @lot }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @lot.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lots/1 or /lots/1.json
  def destroy
    @lot.destroy!

    respond_to do |format|
      format.html { redirect_to lots_path, notice: "Lot was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  # POST /lots/quick_create
  def quick_create
    @lot = Lot.new(
      plant: params[:plant],
      mix_type: params[:mix_type],
      lot_number: generate_next_lot_number(params[:plant], params[:mix_type])
    )

    if @lot.save
      redirect_to @lot, notice: "Lot was successfully created."
    else
      redirect_to lots_path, alert: "Could not create lot: #{@lot.errors.full_messages.join(', ')}"
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lot
      @lot = Lot.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def lot_params
      params.require(:lot).permit(:lot_number, :contractor, :mix_design, :pg, :description, :paving_date, :plant, :mix_type)
    end

    # Generate next sequential lot number for plant+mix combination
    def generate_next_lot_number(plant, mix_type)
      last_lot = Lot.where(plant: plant, mix_type: mix_type).order(created_at: :desc).first
      if last_lot && last_lot.lot_number.match(/\d+$/)
        base = last_lot.lot_number.gsub(/\d+$/, '')
        number = last_lot.lot_number.match(/\d+$/)[0].to_i + 1
        "#{base}#{number}"
      else
        "LOT-1"
      end
    end
end
