# Clear existing data
CoreLocation.destroy_all
CoreGeneration.destroy_all
Lane.destroy_all
Sublot.destroy_all
Lot.destroy_all

# Create a sample lot matching the CSV data
lot = Lot.create!(
  lot_number: "6",
  contractor: "Shamrock Paving",
  mix_design: "P-401",
  pg: "PG 64H-28",
  description: "Phase 1A",
  paving_date: Date.new(2023, 9, 18)
)

puts "Created Lot #{lot.lot_number}"

# Create sublots with lanes matching the CSV
sublot_data = [
  { position: 1, lanes: [
    { position: 1, name: "Lane 1", length_ft: 50, width_ft: 13 },
    { position: 2, name: "Lane 2", length_ft: 570, width_ft: 14 }
  ]},
  { position: 2, lanes: [
    { position: 1, name: "Lane 3", length_ft: 570, width_ft: 13.5 },
    { position: 2, name: "Lane 4", length_ft: 570, width_ft: 11 }
  ]},
  { position: 3, lanes: [
    { position: 1, name: "Lane 5", length_ft: 570, width_ft: 11.5 },
    { position: 2, name: "Lane 6", length_ft: 200, width_ft: 13 }
  ]},
  { position: 4, lanes: [
    { position: 1, name: "Lane 7", length_ft: 170, width_ft: 14 },
    { position: 2, name: "Lane 8", length_ft: 280, width_ft: 12 }
  ]}
]

sublot_data.each do |sublot_info|
  sublot = lot.sublots.create!(
    position: sublot_info[:position],
    name: "Sublot #{sublot_info[:position]}"
  )
  
  sublot_info[:lanes].each do |lane_info|
    sublot.lanes.create!(
      position: lane_info[:position],
      name: lane_info[:name],
      length_ft: lane_info[:length_ft],
      width_ft: lane_info[:width_ft]
    )
  end
  
  puts "  Created Sublot #{sublot.position} with #{sublot.lanes.count} lanes"
end

puts "\nSample data created!"
puts "Lot #{lot.lot_number} has #{lot.sublots.count} sublots and #{lot.lanes.count} total lanes"
