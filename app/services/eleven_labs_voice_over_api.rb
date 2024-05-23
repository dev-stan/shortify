require 'net/http'
require 'uri'
require 'json'

uri = URI.parse("https://api.elevenlabs.io/v1/text-to-speech/21m00Tcm4TlvDq8ikWAM?output_format=mp3_44100_32")
request = Net::HTTP::Post.new(uri)
request.content_type = "application/json"
request["Xi-Api-Key"] = "73813942e4dcdf3f90d59f5e1bd206f9"
request.body = JSON.dump({
  "text" => "he sampling frequency is usually indicated in the file's metadata or header information.",
  "model_id" => "eleven_multilingual_v1",
  "voice_settings" => {
    "stability" => 1,
    "similarity_boost" => 0.25,
    "style" => 0,
    "use_speaker_boost" => true
  }
})

req_options = {
  use_ssl: uri.scheme == "https",
}

response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(request)
end

# file = Uri.open(response.body)

# Cloudinary::Uploader.upload(file)

# response.code
# response.body

require 'fileutils'
FileUtils.mkdir_p(File.dirname('app/assets/audio/example.mp3'))
File.open('app/assets/audio/example1.mp3', 'wb') do |file|
  file.write(response.body)
end
