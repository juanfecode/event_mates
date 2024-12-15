require "uri"
require "open-uri"
require "openai"

# Clear the database to avoid duplicates
Event.destroy_all
Tag.destroy_all
Group.destroy_all
User.destroy_all
FavoriteEvent.destroy_all
Request.destroy_all
EventTag.destroy_all
GroupMessage.destroy_all
UserTag.destroy_all

puts "OpenAI ACCESS Token present? #{ENV['OPENAI_ACCESS_TOKEN'].present?}"

def generate_tags_for_event(event_name)
  client = OpenAI::Client.new

  main_prompt = <<~PROMPT
        Suggest 2-3 relevant music-related tags for the following artist or event:
        Event: #{event_name}

        Tags should be short and related to music genres, styles, or themes.
        Tags should NOT use any special characters like #.
        Please provide them as a comma-separated list.
      PROMPT
  
  prompt = {
    model: "gpt-4o-mini",
    messages: [
      { role: "system", content: "You are a helpful assistant that generates relevant tags for music events." },
      { role: "user", content: main_prompt },
    ],
    temperature: 0.7
  }

  response = client.chat(parameters: prompt)

  # Parse response and return the tags as an array
  response_text = response.dig("choices", 0, "message", "content").to_s.strip.
  response_text.split(",").map( |tag| tag.strip.downcase)
rescue StandardError => e
  puts "Error generating tags for #{event_name}: #{e.message}"
  []
end

# Create events 
csv_path = "storage/events.csv"
csv_events = EventsCsvService.load_from_csv(csv_path)
csv_events.each do |event|
  created_event = Event.create!(
    name: event[:name],
    link: event[:link],
    description: event[:description],
    location: event[:location],
    address: event[:address],
    date: event[:date],
  )
  event_image_url = event[:image]
  if event_image_url.present?
    file = URI.open(event_image_url)
    created_event.image.attach(io: file, filename: File.basename(event_image_url), content_type: file.content_type)
  end

  # if this artist doesn't already have tags generate tags using ChatGPT
  existing_event = Event.find_by(name: created_event[:name])

  if existing_event&.tags&.exists?
  # Reuse tags from the existing event
    generated_tags = []
    existing_event.tags.each do |tag|
      created_event.tags << tag unless created_event.tags.include?(tag)
      generated_tags << tag[:name]
    end
  else
    generated_tags = generate_tags_for_event(event[:name])
    # Create or find tags and associate them with the event
    generated_tags.each do |tag_name|
      tag = Tag.find_or_create_by!(name: tag_name)
      created_event.tags << tag unless created_event.tags.include?(tag)
    end
  end

  puts "Created event: #{created_event.name} with tags: #{generated_tags.join(', ')}"
end

# Create 10 users
users = 10.times.map do |i|
  User.create!(
    email: "user#{i + 1}@example.com",
    password: "password123",
    password_confirmation: "password123"
  )
end

# Assign 3 random tags to each user as user_tags
tags = Tag.all
users.each do |user|
  user.tags << tags.sample(3)
end

# Create 10 groups, each owned by a random user and linked to an event with matching names
events = Event.all
groups = events.map do |event|
  Group.create!(
    bio: "Group for enjoying #{event.name} together",
    event: event,
    user: users.sample
  )
end

# Create requests with specific statuses for users
statuses = %w[rejected accepted pending]

users.each_with_index do |user, index|
  # Skip groups created by the user
  group_to_request = groups.reject { |group| group.user_id == user.id }.sample

  # Ensure no duplicate request exists for the user and group
  unless Request.exists?(user: user, group: group_to_request)
    Request.create!(
      status: statuses[index % 3], # Ensure all statuses are represented
      user: user,
      group: group_to_request,
      event: group_to_request.event
    )
  end
end

# Ensure 2 specific users make 2 requests each to different groups
2.times do |i|
  user = users[i]
  groups_to_request = groups.reject { |group| group.user_id == user.id }

  groups_to_request.sample(2).each do |group|
    # Ensure no duplicate request exists for the user and group
    unless Request.exists?(user: user, group: group)
      Request.create!(
        status: "accepted",
        user: user,
        group: group,
        event: group.event
      )
    end
  end
end

# Favorite events for users

events = Event.all
users = User.all

users.each do |user|
  5.times do
    event = events.sample
    unless FavoriteEvent.exists?(user: user, event: event)
      FavoriteEvent.create!(
        event: event,
        user: user
      )
    end
  end
end

# Output seed completion
puts "Seeding completed!"
puts "#{Tag.count} music-related tags created."
puts "#{Event.count} music events created with real locations and band names."
puts "#{User.count} users created."
puts "#{Group.count} groups created."
puts "#{Request.count} requests created."
puts "#{UserTag.count} user tags created."
