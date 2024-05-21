require "json"
require "open-uri"

url = "https://yt.lemnoslife.com/videos?part=mostReplayed&id=X9G7Md8QI4k"

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

sorted_scores = intensity_scores.sort_by { |score| -score[:intensityScoreNormalized] }

File.open("output.json", "w") do |file|
  file.write(JSON.pretty_generate(sorted_scores))
end

# Print the sorted results
sorted_scores.each do |score|
  puts "Timestamp: #{score[:startMillis]} ms - Intensity Score: #{score[:intensityScoreNormalized]}"
end
