require "shotstack"
require 'json'

# Configure Shotstack
Shotstack.configure do |config|
  config.api_key['x-api-key'] = "xhrTTApBuIrCplrJjRolpCLECrR1yNSHnngKKQiG"
  config.host = "api.shotstack.io"
  config.base_path = "stage"
end

script = "I've known Kim since high school. She's our neighborhood barista now, making the best lattes in town. Every morning, I watch her craft those perfect foam hearts. You wouldn't guess it, but by night, she's a fashion designer. After her shift, she heads straight to her tiny studio, sketching and sewing until the early hours. She's got this incredible energy, balancing both worlds effortlessly. The other day, I saw her hand-delivering a dress to a customer. The look on their face? Pure joy. Kim's not just making coffee or clothes; she's crafting moments of happiness. And that's why she inspires me every single day."

# Split the script into sentences
sentences = script.split(". ")
subtitle_length = 3 # Set the length of each subtitle in seconds
subtitles = []
current_start = 0

# Generate subtitle entries with start time and length
sentences.each do |sentence|
  subtitles << { text: sentence.strip, start: current_start, length: subtitle_length }
  current_start += subtitle_length
end

# Define the video asset and clip
video_asset1 = Shotstack::VideoAsset.new(
  src: "https://f021-223-135-200-101.ngrok-free.app/assets/sample1-7e8fe8ba37a013f250ecd8e62fbff3172fbefa76dd9a3670e3a9db70db7d262e.mp4",
)

video_clip1 = Shotstack::Clip.new(
  asset: video_asset1,
  start: 0,
  length: current_start # Set the length to cover the entire duration of subtitles
)

# Create subtitle clips
subtitle_clips = subtitles.map do |subtitle|
  html_asset = Shotstack::HtmlAsset.new(
    html: "<p style='font-size: 24px; color: white; background: rgba(0, 0, 0, 0.5); padding: 10px;'>#{subtitle[:text]}</p>",
    css: "p { text-align: center; }"
  )

  Shotstack::Clip.new(
    asset: html_asset,
    start: subtitle[:start],
    length: subtitle[:length],
  )
end

# Add both clips to a track
track = Shotstack::Track.new(clips: [video_clip1] + subtitle_clips)

# Add the track to the timeline
timeline = Shotstack::Timeline.new(
  background: "#000000",
  tracks: [track]
)

# Set the video output specification
output = Shotstack::Output.new(
  format: "mp4",
  resolution: "sd",
  aspect_ratio: "9:16",
)

# Create the video edit
edit = Shotstack::Edit.new(
  timeline: timeline,
  output: output
)

# POST the edit to the API
api_client = Shotstack::EditApi.new
response = api_client.post_render(edit).response

# Capture the ID from the response for the next step
id = response.id

# Get the rendered video URL
# Wait for some time for the rendering to complete
start_time = Time.now

while true
  response = api_client.get_render(id, { data: false, merged: true }).response

  if response.status == "done"
    puts ">> Asset URL: #{response.url}"
    break
  else
    elapsed_time = Time.now - start_time
    puts "Rendering is not complete yet. Status: #{response.status}. You've been waiting for #{elapsed_time.round} seconds."
    sleep 1 # Optional: wait for 1 second before checking again
  end
end
