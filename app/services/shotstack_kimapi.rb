require "json"
require 'rest-client'
# video_src = "https://drive.google.com/uc?export=download&id=181aL20cO8Jvvpz4MtWvvyEoysQjyZUdh", # Replace with your video URL
headers = {
  'Content-Type' => 'application/json',
  'Accept' => 'application/json',
  'x-api-key' => 'Xpcjv0luOmE8IelRPkaWe1NHhFeoRjj75YFn3kVF'
}

result_audio = RestClient.post('https://api.shotstack.io/create/stage/assets',
{
  "provider": "shotstack",
  "options": {
    "type": "text-to-speech",
    "text": "Moving down to the Central area we are seeing clear skies, a gentle breeze and mild temperatures, perfect for an evening stroll. Temperatures are hovering around a comfortable 55 degrees fahrenheit, the ideal weather for outdoor activities.",
    "voice": "Matthew",
    "language": "en-US",
    "newscaster": false
  }
}.to_json, headers)

audio_response = JSON.parse(result_audio)
audio_id = audio_response['data']['id']
sleep 5
result = RestClient.get "https://api.shotstack.io/create/stage/assets/#{audio_id}",
headers
result_mp3 = JSON.parse(result)
p mp3_url = result_mp3['data']['attributes']['url']
# asset_url = 'https%3A%2F%2Fshotstack-create-api-stage-assets.s3.amazonaws.com%2Fchre458jq2%2F01hyf-qjm92-96c65-8hcxh-cb46x0.mp3' #response_url['data']['attributes']['url'].gsub('/', '%2F').gsub(':', '%3A')
# sleep 5
# inspected_result = RestClient.get "https://api.shotstack.io/stage/probe/#{asset_url}", headers
# speech_duration = 12.72 #JSON.parse(inspected_result.body)['response']['metadata']['streams'][0]['duration'].to_f
