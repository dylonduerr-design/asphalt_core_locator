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

  def export_xlsx
    @core_generation = @lot.core_generations.includes(core_locations: [:lane, :sublot, :left_lane, :right_lane]).find(params[:id])

    require "caxlsx"

    locations = @core_generation.core_locations.order(:mark).to_a
    sublot_positions = locations.map { |loc| loc.sublot&.position }.compact.uniq.sort

    package = Axlsx::Package.new
    workbook = package.workbook
    styles = workbook.styles

    # Template colors provided by user:
    # - MAT rows:   #CCFFFF
    # - JOINT rows: #FFFFCC
    # - Lot Dist + Sublot Linear columns: #BFBFBF
    mat_bg = "CCFFFF"
    joint_bg = "FFFFCC"
    dist_bg = "BFBFBF"

    header_style = styles.add_style(
      b: true,
      bg_color: "FFFFFF",
      fg_color: "000000",
      alignment: { horizontal: :center, vertical: :center },
      border: Axlsx::STYLE_THIN_BORDER
    )

    text_left = styles.add_style(
      alignment: { horizontal: :left, vertical: :center },
      border: Axlsx::STYLE_THIN_BORDER
    )
    text_left_bold = styles.add_style(
      b: true,
      alignment: { horizontal: :left, vertical: :center },
      border: Axlsx::STYLE_THIN_BORDER
    )
    text_left_mat = styles.add_style(
      bg_color: mat_bg,
      alignment: { horizontal: :left, vertical: :center },
      border: Axlsx::STYLE_THIN_BORDER
    )
    text_left_joint = styles.add_style(
      bg_color: joint_bg,
      alignment: { horizontal: :left, vertical: :center },
      border: Axlsx::STYLE_THIN_BORDER
    )
    text_left_mat_bold = styles.add_style(
      bg_color: mat_bg,
      b: true,
      alignment: { horizontal: :left, vertical: :center },
      border: Axlsx::STYLE_THIN_BORDER
    )
    text_left_joint_bold = styles.add_style(
      bg_color: joint_bg,
      b: true,
      alignment: { horizontal: :left, vertical: :center },
      border: Axlsx::STYLE_THIN_BORDER
    )

    num_right = styles.add_style(
      num_fmt: 2,
      alignment: { horizontal: :right, vertical: :center },
      border: Axlsx::STYLE_THIN_BORDER
    )
    num_right_mat = styles.add_style(
      bg_color: mat_bg,
      num_fmt: 2,
      alignment: { horizontal: :right, vertical: :center },
      border: Axlsx::STYLE_THIN_BORDER
    )
    num_right_joint = styles.add_style(
      bg_color: joint_bg,
      num_fmt: 2,
      alignment: { horizontal: :right, vertical: :center },
      border: Axlsx::STYLE_THIN_BORDER
    )
    num_right_dist = styles.add_style(
      bg_color: dist_bg,
      num_fmt: 2,
      alignment: { horizontal: :right, vertical: :center },
      border: Axlsx::STYLE_THIN_BORDER
    )

    rand_right_mat = styles.add_style(
      bg_color: mat_bg,
      alignment: { horizontal: :right, vertical: :center },
      border: Axlsx::STYLE_THIN_BORDER
    )
    rand_right_joint = styles.add_style(
      bg_color: joint_bg,
      alignment: { horizontal: :right, vertical: :center },
      border: Axlsx::STYLE_THIN_BORDER
    )
    na_right_mat = styles.add_style(
      bg_color: mat_bg,
      i: true,
      alignment: { horizontal: :right, vertical: :center },
      border: Axlsx::STYLE_THIN_BORDER
    )
    na_right_joint = styles.add_style(
      bg_color: joint_bg,
      i: true,
      alignment: { horizontal: :right, vertical: :center },
      border: Axlsx::STYLE_THIN_BORDER
    )

    workbook.add_worksheet(name: "Core Locations") do |sheet|
      sheet.add_row(
        [
          "Mark",
          "Type",
          "Sublot",
          "Lane",
          "Lot Dist (ft)",
          "Sublot Linear (ft)",
          "Station in Lane (ft)",
          "Offset in Lane (ft)",
          "Random (A)",
          "Random (B)"
        ],
        style: Array.new(10, header_style),
        height: 20
      )

      locations.each do |loc|
        type_value = loc.core_type.to_s.downcase

        row_bg = (type_value == "joint") ? :joint : :mat

        lane_value = if type_value == "joint"
          left = loc.left_lane&.position || loc.left_lane_id
          right = loc.right_lane&.position || loc.right_lane_id
          if left.present? && right.present?
            "lanes #{left}/#{right}"
          else
            "lanes"
          end
        else
          loc.lane_index
        end

        rand_a_val = loc.station_random_number.present? ? format("%.4f", loc.station_random_number.to_f) : "N/A"
        rand_b_val = loc.offset_random_number.present? ? format("%.4f", loc.offset_random_number.to_f) : "N/A"

        row = [
          loc.mark,
          type_value,
          loc.sublot&.position,
          lane_value,
          loc.distance_from_lot_start_ft,
          loc.linear_in_sublot_ft,
          loc.station_in_lane_ft,
          loc.offset_in_lane_ft,
          rand_a_val,
          rand_b_val
        ]

        is_joint = row_bg == :joint
        text_bg = is_joint ? text_left_joint : text_left_mat
        mark_bg = is_joint ? text_left_joint_bold : text_left_mat_bold
        num_bg = is_joint ? num_right_joint : num_right_mat
        rand_bg = is_joint ? rand_right_joint : rand_right_mat

        row_styles = [
          mark_bg,         # Mark
          text_bg,         # Type
          text_bg,         # Sublot
          text_bg,         # Lane
          num_right_dist,  # Lot Dist (ft) - always grey
          num_right_dist,  # Sublot Linear (ft) - always grey
          num_bg,          # Station in Lane (ft)
          num_bg,          # Offset in Lane (ft)
          (rand_a_val == "N/A" ? (is_joint ? na_right_joint : na_right_mat) : rand_bg),
          (rand_b_val == "N/A" ? (is_joint ? na_right_joint : na_right_mat) : rand_bg)
        ]

        sheet.add_row(row, style: row_styles, height: 20)
      end

      # Add blank lines (like the provided template) for easy printing/notes
      20.times do
        sheet.add_row(Array.new(10, nil))
      end

      # Freeze header row (caxlsx doesn't support freeze_panes=)
      if sheet.respond_to?(:sheet_view) && sheet.sheet_view.respond_to?(:pane)
        sheet.sheet_view.pane do |pane|
          pane.state = :frozen
          pane.y_split = 1
          pane.top_left_cell = "A2"
          pane.active_pane = :bottom_left
        end
      end
      sheet.column_widths 18, 10, 8, 16, 14, 18, 20, 18, 12, 12
    end

    filename = xlsx_export_filename(
      mix_type: @lot.mix_type,
      lot_number: @lot.lot_number,
      sublot_positions: sublot_positions,
      date: Time.zone.today
    )

    send_data package.to_stream.read,
              filename: filename,
              type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
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

  def xlsx_export_filename(mix_type:, lot_number:, sublot_positions:, date:)
    range = if sublot_positions.present?
      min, max = sublot_positions.minmax
      min == max ? min.to_s : "#{min}-#{max}"
    else
      ""
    end

    date_str = date.strftime("%m-%d-%Y")
    base = "#{mix_type}_CORES_#{lot_number}"
    base += "_Sub_#{range}" if range.present?
    base += "_#{date_str}.xlsx"

    # Windows/macOS safe filename sanitization (slashes not allowed)
    base.tr("/\\:", "---").gsub(" ", "_")
  end
end
