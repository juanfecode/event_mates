require "selenium-webdriver"
require "nokogiri"

class BandsintownScraperService
  BASE_URL = "https://www.bandsintown.com/c/buenos-aires-argentina?came_from=253&utm_medium=web&utm_source=city_page&utm_campaign=top_event&sort_by_filter=Number+of+RSVPs&concerts=true"

  def self.scrape_events
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless') # Run without a GUI
    options.add_argument('--disable-gpu')
    options.add_argument('--no-sandbox')
    #options.add_argument('--disable-javascript') # DEBUGGING...
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
      wait.until { driver.find_elements(css: ".HsqHp2xM2FkfSdjy1mlU").any? }
      puts "Event links loaded."

      # Extract event links
      event_elements = driver.find_elements(css: ".HsqHp2xM2FkfSdjy1mlU")
      event_links = event_elements.first(25).map { |el| el.attribute("href") } # Limit to 25

      # Iterate over each event link
      event_links.each_with_index do |event_link, index|

        # Debugging... THIS WILL BE DELETED
        puts "Fetching event #{index + 1}: #{event_link}"

        # Simulate Human Behavior
        #driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
        #sleep(3)
        #puts "scrolling..."

        # Navigate to the event page
        link_element = driver.find_element(css: "a[href='#{event_link}']")
        link_element.click
        sleep(3)
        puts "Navigated to: #{driver.current_url}"

        # close pop-up if it opens
        dismiss_popup(driver)
        wait.until { driver.find_element(css: "h1.Ei9BArGnSZVOQUo8LHDo") } # Wait for the title to load

        # Get page source and parse it with Nokogiri
        event_doc = Nokogiri::HTML(driver.page_source)

        # Extract event details
        event_name = event_doc.at_css('h1.Ei9BArGnSZVOQUo8LHDo')&.text&.strip
        full_description = "None provided"
        event_description = full_description[0, 500]
        event_location = event_doc.at_css('a.q1Vlsw1cdclAUZ4gBvAn ')&.text&.strip
        event_date_text = event_doc.at_css('h2.EfW1v6YNlQnbyB7fUHmR')&.text&.strip
        event_date = DateTime.strptime(event_date_text, "%b %d, %Y").strftime("%Y-%m-%d")

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

def dismiss_popup(driver)
  begin
    # Adjust the selector to target the popup's close button
    close_button = driver.find_element(css: 'div.ImIP7Nc4vngjZ8u6Z7_e') 
    if close_button.displayed?
      puts "Popup detected. Closing it."
      close_button.click
      sleep(2) # Allow time for the popup to close
    end
  rescue Selenium::WebDriver::Error::NoSuchElementError
    puts "No popup detected."
  end
end

BandsintownScraperService.scrape_events