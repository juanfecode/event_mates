require "selenium-webdriver"
require "nokogiri"

class EventbriteScraperService
  BASE_URL = "https://www.eventbrite.com/b/argentina--buenos-aires/nightlife/?category=music"

  def self.scrape_events
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless') # Run without a GUI
    options.add_argument('--disable-gpu')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage') # Useful for Docker

    driver = Selenium::WebDriver.for(:chrome, options: options)
    events = []

    begin
      # Navigate to the main page
      driver.navigate.to(BASE_URL)
      wait = Selenium::WebDriver::Wait.new(timeout: 10) # Wait for elements to load

      # debugging... THIS WILL BE DELETED
      puts "Navigated to #{BASE_URL}"

      # Wait for event links to appear
      wait.until { driver.find_elements(css: ".event-card-link").any? }
      puts "Event links loaded."

      # Extract event links
      event_elements = driver.find_elements(css: ".event-card-link")
      event_links = event_elements.first(25).map { |el| el.attribute("href") } # Limit to 25

      # Iterate over each event link
      event_links.each_with_index do |event_link, index|

        # Debugging... THIS WILL BE DELETED
        puts "Fetching event #{index + 1}: #{event_link}"

        # Navigate to the event page
        driver.navigate.to(event_link)
        wait.until { driver.find_element(css: "h1.event-title.css-0") } # Wait for the title to load

        # Get page source and parse it with Nokogiri
        event_doc = Nokogiri::HTML(driver.page_source)

        # Extract event details
        event_name = event_doc.at_css('h1.event-title.css-0')&.text&.strip
        full_description = event_doc.css('#event-description p').map(&:text).join("\n")
        event_description = full_description[0, 500]
        event_location = event_doc.at_css('section[aria-labelledby="location-heading"] .location-info__address-text')&.text&.strip
        event_date = event_doc.at_css('time.start-date')&.[]('datetime')

        # Prevent duplicates... THIS WILL NEED TO BE UPDATED
        if events.any? { |e| e[:name] == event_name && e[:date] == event_date }
          puts "Skipping duplicate: #{event_name}"
          next
        end

        # Store the event in an array... THIS WILL NEED TO BE UPDATED
        events << {
          name: event_name,
          description: event_description,
          location: event_location,
          date: event_date
        }

        # Debug output... THIS WILL BE DELETED
        puts "#{index + 1}. #{event_name}"
        puts "\tDate: #{event_date}"
        puts "\tLocation: #{event_location}"
        puts "\tDescription: #{event_description}\n\n"
      end
    ensure
      # Ensure the browser is always closed
      driver.quit
    end

    events
  end
end

EventbriteScraperService.scrape_events