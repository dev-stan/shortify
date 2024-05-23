# Step 1: Install the Shotstack gem
# gem install shotstack

# Step 2: Require the gem
require "shotstack"
require "json"

# Step 3: Authentication and configuration
Shotstack.configure do |config|
  config.api_key['x-api-key'] = "	x9mGrTYVINGV52BTk0i1cQ6bdlk2ty7WgK9i1SU1"
  config.host = "api.shotstack.io"
  config.base_path = "stage"
end


# Step 4: Define video assets and clips
video_asset1 = Shotstack::VideoAsset.new(
  src: "https://drive.google.com/uc?export=download&id=181aL20cO8Jvvpz4MtWvvyEoysQjyZUdh", # Replace with your video URL
)

video_clip1 = Shotstack::Clip.new(
  asset: video_asset1,
  start: 0,
  length: 5
  # loop: true, # Start from the beginning of the video
  # length: 20 # Length of the clip (in seconds)
)

# Step 5: Create a track and add clips to it
track = Shotstack::Track.new(clips: [video_clip1])

# Step 6: Create a timeline and add the track to it
timeline = Shotstack::Timeline.new(
  background: "#000000", # Background color (black in this case)
  tracks: [track]
)

# Step 7: Set the video output specification
output = Shotstack::Output.new(
  format: "mp4", # Output format
  resolution: "sd", # Resolution (standard definition)
  aspect_ratio: "9:16" # Aspect ratio (vertical for TikTok Shorts)
)

# Step 8: Create the video edit
edit = Shotstack::Edit.new(
  timeline: timeline,
  output: output
)

# Step 9: POST the edit to the API
api_client = Shotstack::EditApi.new
response = api_client.post_render(edit).response

# Step 10: Get the rendered video URLs
# Wait for the rendering to complete
start_time = Time.now

while true
  response = api_client.get_render(response.id, { data: false, merged: true }).response

  if response.status == "done"
    puts ">> Rendered video URL: #{response.url}"
    break
  else
    elapsed_time = Time.now - start_time
    puts "Rendering is not complete yet. Status: #{response.status}. Elapsed time: #{elapsed_time.round} seconds."
    sleep 1 # Wait for 1 second before checking again
  end
end
