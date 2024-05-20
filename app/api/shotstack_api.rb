# Step 1: Install the Shotstack gem
# gem install shotstack

# Step 2: Require the gem
require "shotstack"

# Step 3: Authentication and configuration
Shotstack.configure do |config|
  config.api_key['x-api-key'] = "xhrTTApBuIrCplrJjRolpCLECrR1yNSHnngKKQiG"
  config.host = "api.shotstack.io"
  config.base_path = "stage"
end

# Step 4: Trim the first video (clip1)
video_asset1 = Shotstack::VideoAsset.new(
  src: "https://s3-ap-southeast-2.amazonaws.com/shotstack-assets/footage/skater.hd.mp4",
  trim: 3
)

video_clip1 = Shotstack::Clip.new(
  asset: video_asset1,
  start: 0,
  length: 5
)

# Step 5: Add the second video (clip2)
video_asset2 = Shotstack::VideoAsset.new(
  src: "https://i.imgur.com/cWxfcYJ.mp4"
)

video_clip2 = Shotstack::Clip.new(
  asset: video_asset2,
  start: 5,  # Start immediately after the first clip
  length: 5
)

# Step 6: Add both clips to a track
track = Shotstack::Track.new(clips: [video_clip1, video_clip2])

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
    sleep 5 # Optional: wait for 5 seconds before checking again
  end
end
