# this comment is just to resolve github connection problem
require "nokogiri"
require "open-uri"

class EventScraperService
  BASE_URL = "https://www.eventbrite.com/b/argentina--buenos-aires/nightlife/?category=music"
  USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:133.0) Gecko/20100101 Firefox/133.0"

  def self.scrape_events
    puts BASE_URL
    html_content = URI.open(BASE_URL, "User-Agent" => USER_AGENT).read
    puts "Fetched HTML Content: #{html_content[0..1000]}"
    doc = Nokogiri::HTML.parse(html_content)
    events = []

    # First we start on a web page that shows a bunch of events 
    # This CSS selector targets all <a> tags with an id that begins with event-card-link class
    doc.search(".event-card-link").each_with_index do |element, index|

      # Debug
      puts "Found event link: #{element['href']}"
      
      # Avoid 429 too many requests
      break if index >= 25
      sleep(2) 
      
      event_link = element["href"]
      # Now we begin extraction of the the info of the event from individual webpages 
      event_url = event_link

      # fetch HTML content from the URL
      event_html_content = URI.open(event_url , "User-Agent" => USER_AGENT).read
      event_doc = Nokogiri::HTML::parse(event_html_content)

      # Extract Event Name
      event_name_element = event_doc.at_css('h1.event-title.css-0')
      event_name = event_name_element.text.strip if event_name_element

      # Extract Event Description
      event_description_elements = event_doc.css('#event-description p')
      event_description = []
      event_description_elements.each do |p|
        event_description << p.text.strip
      end
      event_description = event_description.join("\n")

      # Extract Event Location
      event_location_element = event_doc.at_css('section[aria-labelledby="location-heading"] .location-info__address-text')
      location_text = event_location_element.text.strip if event_location_element

      # Extract Event Address
      event_address_element = event_doc.at_css('section[aria-labelledby="location-heading"] .location-info__address')
      address_text = event_address_element.children.reject { |node| node.element? }.map(&:text).join.strip if event_address_element

      event_location = "#{location_text}\n#{address_text}"

      # Extract Event Date
      event_time_element = event_doc.at_css('time.start-date')
      event_date = event_time_element['datetime'] if event_time_element


      # this is just for testing purposes
      puts "#{index +1}. #{event_name}\n\tEvent Date: #{event_date}\n\tevent location: #{event_location}\n\tEvent Description: #{event_description}\n\n"
      # Store the info in a hash and store that in an array
      events << {name: event_name, event_location: event_location, event_description: event_description, event_date: event_date}
    end
    return events
  end
end

  EventScraperService.scrape_events
  
