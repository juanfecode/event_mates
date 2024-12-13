require "csv"

class EventsCsvService

  def self.save_to_csv(events)
    csv_path = "storage/events.csv"
    CSV.open(csv_path, "wb") do |csv|
      csv << ["Name", "Description", "Location", "Address", "Date", "Image"]
      events.each do |event|
        csv << [
          event[:name],
          event[:description],
          event[:location],
          event[:address],
          event[:date],
          event[:image]
        ]
      end
    end
    puts "Events saved to events.csv"
  end

  def self.load_from_csv(csv_path)
    return [] unless File.exist?(csv_path)

    events = []
    CSV.foreach(csv_path, headers: true) do |row|
      events << {
        name: row["Name"],
        description: row["Description"],
        location: row["Location"],
        address: row["Address"],
        date: row["Date"],
        image: row["Image"]
      }
    end
    puts "Loaded #{events.size} events from CSV."
    events
  end
end