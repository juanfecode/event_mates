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
  response_text = response.dig("choices", 0, "message", "content").to_s.strip
  response_text.split(",").map{ |tag| tag.strip.downcase }
rescue StandardError => e
  puts "Error generating tags for #{event_name}: #{e.message}"
  []
end

def generate_user_bio(user)
  client = OpenAI::Client.new

  # Construct the prompt using user details
  main_prompt = <<~PROMPT
    Create a short, engaging 3-sentence bio for a user based on the following details:
    - First Name: #{user.first_name}
    - Last Name: #{user.last_name}
    - Hometown: #{user.hometown}
    - Age: #{(Date.today.year - user.dob.year)} (approximate age based on DOB)
    - Interests: Create a personality and fictional hobbies for this user.

    The bio should sound natural and relatable, reflecting a friendly tone. Do not include placeholder text like "First Name" or "Hometown." Just output the bio directly.
  PROMPT

  # Make API call to GPT-4
  response = client.chat(
    parameters: {
      model: "gpt-4o-mini",
      messages: [
        { role: "system", content: "You are a creative assistant for generating short user bios." },
        { role: "user", content: main_prompt }
      ],
      temperature: 0.7
    }
  )

  # Parse and return the bio
  response_text = response.dig("choices", 0, "message", "content").to_s.strip
  response_text
rescue StandardError => e
  puts "Error generating bio for #{user.first_name} #{user.last_name}: #{e.message}"
  "A friendly user from #{user.hometown}."
end

# List of 20 image prompts
IMAGE_PROMPTS = [
  "Generate a realistic photo of a female cooking in a modern kitchen. She should appear focused and relaxed, surrounded by fresh ingredients in a well-lit, warm environment. The scene should feel inviting and natural, with a clear focus on her cooking process.",
  "Generate a realistic photo of a female reading a book in a cozy indoor setting. She should appear calm and engrossed, sitting on a comfortable chair with warm lighting. The scene should feel serene and intimate, highlighting her focus on the book.",
  "Generate a realistic photo of a female reading a book in a cozy indoor setting. She should appear calm and engrossed, sitting on a comfortable chair with warm lighting. The scene should feel serene and intimate, highlighting her focus on the book.",
  "Generate a realistic photo of a female hiking in a scenic outdoor environment. She should appear energetic and adventurous, surrounded by trees and mountains in natural lighting. The atmosphere should be fresh and dynamic, showcasing her love for nature.",
  "Generate a realistic photo of a female playing guitar in a cozy studio. She should appear creative and focused, sitting on a stool with soft, natural lighting and an artistic vibe in the background.",
  "Generate a realistic photo of a female painting on a canvas in a bright, modern studio. She should appear inspired and relaxed, with paints and brushes around her, and natural light streaming in.",
  "Generate a realistic photo of a female working on a laptop in a trendy coffee shop. She should appear focused and productive, with a cup of coffee nearby, in a well-lit and modern setting.",
  "Generate a realistic photo of a female jogging in a park during the morning. She should appear energetic and motivated, wearing comfortable athletic wear, surrounded by greenery.",
  "Generate a realistic photo of a female playing with a dog in a sunny backyard. She should appear cheerful and relaxed, with the dog excitedly engaging with her.",
  "Generate a realistic photo of a female practicing yoga in a serene indoor setting. She should appear calm and focused, performing a pose on a yoga mat with soft natural light.",
  "Generate a realistic photo of a female shopping for groceries in a bright, modern supermarket. She should appear thoughtful and friendly, examining fresh produce in a well-organized aisle.",
  "Generate a realistic photo of a male cooking in a stylish modern kitchen. He should appear focused and relaxed, surrounded by fresh ingredients, with warm, inviting lighting highlighting the scene.",
  "Generate a realistic photo of a male reading a book by a large window with natural light. He should appear thoughtful and engrossed, sitting comfortably in a modern armchair.",
  "Generate a realistic photo of a male hiking through a rugged outdoor trail. He should appear adventurous and energetic, with mountains and trees in the background under clear natural light.",
  "Generate a realistic photo of a male playing piano in a cozy music studio. He should appear focused and creative, with soft lighting emphasizing the musical atmosphere.",
  "Generate a realistic photo of a male building furniture in a workshop. He should appear skilled and focused, surrounded by tools and wood in a bright, practical setting.",
  "Generate a realistic photo of a male exercising with weights in a modern gym. He should appear determined and energetic, surrounded by sleek workout equipment.",
  "Generate a realistic photo of a male drinking coffee in a trendy urban café. He should appear relaxed and thoughtful, with natural light and a stylish interior in the background.",
  "Generate a realistic photo of a male fixing a bicycle outdoors. He should appear focused and engaged, with tools in hand and a warm, sunny day setting the mood.",
  "Generate a realistic photo of a male fishing by a serene lake. He should appear calm and focused, with fishing gear and the peaceful water reflecting the natural surroundings."
]

# Method to generate a user image using DALL·E
def generate_user_image
  client = OpenAI::Client.new

  # Pick a random prompt from the list
  image_prompt = IMAGE_PROMPTS.sample

  # Make API call to generate the image
  response = client.images.generate(
    parameters: {
      model: "dall-e-2",
      prompt: image_prompt,
      n: 1,
      size: "256x256"
    }
  )

  # Return the image URL
  response.dig("data", 0, "url")
rescue StandardError => e
  puts "Error generating image: #{e.message}"
  nil
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

# Create 30 users with details and images
users = 30.times.map do |i|

  # Create the user
  user = User.create!(
    email: "user#{i + 1}@example.com",
    password: "password123",
    password_confirmation: "password123",
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    dob: Faker::Date.birthday(min_age: 20, max_age: 40),
    phone_number: Faker::PhoneNumber.phone_number,
    hometown: "#{Faker::Address.city}, #{Faker::Address.state_abbr}"
  )

  # Generate the bio
  user.update!(bio: generate_user_bio(user))
  sleep(1)
  # Generate and attach the image
  image_url = generate_user_image
  
  if image_url
    file = URI.open(image_url)
    user.photo.attach(io: file, filename: "user#{i + 1}.png", content_type: "image/png")
  end

  puts "Created user: #{user.email} - #{user.first_name} #{user.last_name}"
  user
end

# Assign 3 random tags to each user as user_tags
tags = Tag.all
users.each do |user|
  user.tags << tags.sample(6)
end

# Create 10 groups, each owned by a random user and linked to an event with matching names
events = Event.all
groups = events.map do |event|
  Group.create!(
    bio: "lets enjoy #{event.name} together",
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
  15.times do
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
