namespace :astm do
  desc "Load ASTM D3665 random numbers from CSV"
  task load_random_numbers: :environment do
    require 'csv'
    
    csv_path = Rails.root.join('db', 'astm_d3665_random_numbers.csv')
    
    unless File.exist?(csv_path)
      puts "CSV file not found at #{csv_path}"
      puts "Please create the file with ASTM D3665 random numbers"
      exit 1
    end
    
    AstmRandomNumber.delete_all
    
    CSV.foreach(csv_path, headers: true) do |row|
      row_num = row['Row'].to_i
      (1..20).each do |col|
        value = row[col.to_s]&.to_f
        next if value.nil?
        
        AstmRandomNumber.create!(
          row: row_num,
          column: col,
          value: value
        )
      end
    end
    
    puts "Loaded #{AstmRandomNumber.count} random numbers from ASTM D3665 table"
  end
end
