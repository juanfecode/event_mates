require "uri"
require "open-uri"

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

# Create 40 music-related tags
tag_names = [
  "rock", "hip hop", "jazz", "lo fi", "ambient", "electronic", "pop",
  "punk", "metal", "reggae", "blues", "salsa", "techno", "disco", "folk",
  "classical", "house", "trance", "synthwave", "karaoke", "spoken word",
  "acoustic", "indie", "progressive", "melodic", "vocals", "instrumental",
  "dj set", "festival", "gig", "concert", "playlist", "live session",
  "cover band", "open mic", "jam session", "soundtrack", "choir", "opera",
  "studio recording", "performance"
]

tags = tag_names.map { |name| Tag.create!(name: name) }

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
end

# Assign 3 random tags to each event
events = Event.all
events.each { |event| event.tags << tags.sample(3) }

# Create 10 users
users = 10.times.map do |i|
  User.create!(
    email: "user#{i + 1}@example.com",
    password: "password123",
    password_confirmation: "password123"
  )
end

# Assign 3 random tags to each user as user_tags
users.each do |user|
  user_tags = tags.sample(3)
  user_tags.each do |tag|
    UserTag.create!(user: user, tag: tag)
  end
end

# Create 10 groups, each owned by a random user and linked to an event with matching names
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
