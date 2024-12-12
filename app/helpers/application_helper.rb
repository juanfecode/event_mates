module ApplicationHelper
  def calculate_age(dob)
    return "N/A" unless dob # Handle cases where DOB is nil

    # Calculate age
    now = Date.today
    age = now.year - dob.year
    age -= 1 if dob > now.yesterday.change(year: now.year) # Adjust if birthday hasn't occurred yet this year
    age
  end
end
