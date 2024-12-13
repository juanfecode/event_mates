require "selenium-webdriver"
require "nokogiri"

class JambaseScraperService
  BASE_URL = "https://www.jambase.com/concerts/ar/~/concerts-in-buenos-aires"

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

      # DEBUGGING
      # puts "Navigated to #{BASE_URL}"

      # Wait for event links to appear
      wait.until { driver.find_elements(css: ".thumbnail").any? }

      # Extract event links
      event_elements = driver.find_elements(css: ".thumbnail")
      event_links = event_elements.first(25).map { |el| el.attribute("href") } # Limit to 25

      # Iterate over each event link
      event_links.each_with_index do |event_link, index|

        # DEBUGGING
        # puts "Fetching event #{index + 1}: #{event_link}"

        # Navigate to the event page
        driver.navigate.to(event_link)
        wait.until { driver.find_element(css: "h1.post-title") } # Wait for the title to load

        # Get page source and parse it with Nokogiri
        event_doc = Nokogiri::HTML(driver.page_source)

        # Extract event details
        event_name = event_doc.at_css('h1.post-title')&.xpath('text()')&.text&.strip
        full_description = "not provided"
        event_description = full_description[0, 500]
        event_location = event_doc.at_css('div.mb-2 strong')&.text&.strip
        event_address = event_doc.css('ul.list-unstyled.address-structured li').map(&:text).map(&:strip).join(", ")
        event_date_elements = event_doc.css('ul.list-inline.list-inline-delimited li')
        event_date_texts = event_date_elements.map(&:text).map(&:strip)
        # DEBUG puts "Extracted event_date_text: #{event_date_texts[2].inspect}"
        event_date = Date.strptime(event_date_texts[2], "%b %d, %Y").strftime("%Y-%m-%d") if event_date_texts
        event_image_element = event_doc.at_css('img.cld-responsive')
        event_image = event_image_element&.[]('src')

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
          date: event_date,
          image: event_image
        }

        # Debug output... THIS WILL BE DELETED
        puts "#{index + 1}. #{event_name}"
        puts "\tDate: #{event_date}"
        puts "\tLocation: #{event_location}"
        puts "\tDescription: #{event_description}"
        puts "\tImage: #{event_image}\n\n"
      end
    ensure
      # Ensure the browser is always closed
      driver.quit
    end

    events
  end
end

JambaseScraperService.scrape_events