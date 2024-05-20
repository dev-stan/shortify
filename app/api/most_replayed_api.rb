require "json"
require "open-uri"

# API URL
url = "https://yt.lemnoslife.com/videos?part=mostReplayed&id=srRQQXoPqGg"

# Fetch and parse the JSON data from the API
response_serialized = URI.open(url).read
response = JSON.parse(response_serialized)

# Extract intensity scores and their corresponding timestamps
intensity_scores = response["items"][0]["mostReplayed"]["markers"].map do |marker|
  {
    startMillis: marker["startMillis"],
    intensityScoreNormalized: marker["intensityScoreNormalized"]
  }
end

# Sort the scores from highest to lowest
sorted_scores = intensity_scores.sort_by { |score| -score[:intensityScoreNormalized] }

# Print the sorted results
sorted_scores.each do |score|
  puts "Timestamp: #{score[:startMillis]} ms - Intensity Score: #{score[:intensityScoreNormalized]}"
end
