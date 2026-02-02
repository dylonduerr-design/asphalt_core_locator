# Asphalt Core Locator

A Rails 7 web application for generating random asphalt mat and joint core sample locations with per-lane geometry support.

## Features

- **Lot Management**: Create lots with metadata (contractor, mix design, PG rating, etc.)
- **Flexible Sublot/Lane Configuration**: Each sublot can have multiple lanes with individual lengths and widths
- **Lane-Aware Core Generation**:
  - Mat cores: randomly placed within lanes using weighted selection by lane length
  - Joint cores: placed between adjacent lanes
  - Supports variable lane dimensions within each sublot
- **Configurable Sampling Rules**:
  - Rounding increment: 0.5 ft (default)
  - Mat edge buffer: 1 ft from each lane edge (default)
  - Lane start buffer: 10 ft from lane start (default)
  - Adjustable number of mat/joint cores
- **Reproducible Results**: Optional seed for deterministic generation
- **Detailed Outputs**:
  - Lane-linear distance (concatenated lane lengths)
  - Station-in-lane
  - Lane-relative offset
  - Distance from lot start
  - Human-readable marks (e.g., `M 6-1-1`, `J 6-2-1/2-1`)
- **CSV Export**: Download results in spreadsheet format

## Quick Start

### Prerequisites
- Ruby 3.2.2
- PostgreSQL
- Rails 7.1.6

### Installation

```bash
# Install dependencies
bundle install

# Create and setup database
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed  # Optional: loads sample data

# Start the server
bin/rails server
```

Visit http://localhost:3000

### Sample Data

The seed file creates a sample lot (Lot #6 from Shamrock Paving) with 4 sublots and 8 lanes.

## Usage

1. **Create a Lot**: Click "New Lot" and enter project details
2. **Add Sublots**: From the lot page, add sublots in order
3. **Add Lanes**: For each sublot, add lanes left-to-right with their lengths and widths
4. **Generate Cores**: Click "Generate core locations" and configure sampling settings
5. **View Results**: See the generated core locations with all coordinates
6. **Export CSV**: Download results for field use

## How It Works

### Lane-Linear Distance Calculation

For a sublot with lanes [L1: 50ft, L2: 570ft]:
- Total lane-linear = 620 ft
- A core at 332 ft lane-linear means:
  - Lane index: 2 (because 332 > 50, so it's in L2)
  - Station in lane: 332 - 50 = 282 ft into L2

### Sampling Algorithm

1. **Pick lane** (mat cores): weighted random by lane length
2. **Pick station**: random within [start_buffer, lane_length], rounded to grid
3. **Pick offset** (mat cores): random within [edge_buffer, width - edge_buffer], rounded to grid
4. **Compute outputs**:
   - Lane-linear in sublot = Σ(prior lane lengths) + station
   - Distance from lot start = Σ(all prior sublots' lane-linear totals) + lane-linear in sublot

### Joints

Joints exist between each pair of adjacent lanes (1-2, 2-3, etc.). Joint length = min(left_lane.length, right_lane.length). Offset is fixed at the lane boundary.

## License

Private project.
