# Step 1: Install the Shotstack gem
# gem install shotstack

# SAMPLE VIDEO LINK
# https://drive.google.com/uc?export=download&id=1gB53ZKM7FMFjGAyQKKTe5ld6nvNxhQIF





# Step 2: Require the gem
require "shotstack"
require 'json'


file = File.read('output.json')
data_hash = JSON.parse(file)
best_seconds = data_hash[0]['startMillis'] / 1000
p best_seconds


# Step 3: Authentication and configuration
Shotstack.configure do |config|
  config.api_key['x-api-key'] = "xhrTTApBuIrCplrJjRolpCLECrR1yNSHnngKKQiG"
  config.host = "api.shotstack.io"
  config.base_path = "stage"
end

# Step 4: Trim the first video (clip1)
video_asset1 = Shotstack::VideoAsset.new(
  src: "https://f606-223-135-200-101.ngrok-free.app/assets/sample-a2392780362d05aa22d41765ba66ca56c7b32260b3ebe188d1b4c79eb14583ec.mp4",
  trim: best_seconds - 10
)

video_clip1 = Shotstack::Clip.new(
  asset: video_asset1,
  start: 0,
  length: 10,
  # Set the scale property to maintain a 9:16 aspect ratio
)

# Step 6: Add both clips to a track
track = Shotstack::Track.new(clips: [video_clip1])

# Step 7: Add the track to the timeline
timeline = Shotstack::Timeline.new(
  background: "#000000",
  tracks: [track]
)

# Step 8: Set the video output specification
output = Shotstack::Output.new(
  format: "mp4",
  resolution: "sd"
)

# Step 9: Create the video edit
edit = Shotstack::Edit.new(
  timeline: timeline,
  output: output
)

# Step 10: POST the edit to the API
api_client = Shotstack::EditApi.new
response = api_client.post_render(edit).response

# Capture the ID from the response for the next step
id = response.id

# Step 11: Get the rendered video URL
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
    sleep 1 # Optional: wait for 5 seconds before checking again
  end
end
