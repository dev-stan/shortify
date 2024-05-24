# app/services/openai_service.rb
require "openai"
require 'open-uri'
require 'base64'
require 'tempfile'
require "json"
require 'rest-client'

class GenerateVideo
  attr_reader :client

  def initialize(source_url, script)
    @source_url = source_url
    @script = script
    @client = OpenAI::Client.new(
      access_token: $OPENAI_ACCESS_TOKEN,
      log_errors: true # Highly recommended in development, so you can see what errors OpenAI is returning. Not recommended in production.
    )
    @headers = {
      'Content-Type' => 'application/json',
      'Accept' => 'application/json',
      'x-api-key' => 'u9MgtKJAMx0HFO6lAHNY2sqCbW7hQ40khGd47NPC'
      }
  end

  def final_video_link
    p 'creating mp3'
    @mp3_url = create_mp3(@script)  # Ensure MP3 is created first and the URL is stored
    p 'creating subtitle'
    subtitles = call_whisper(@mp3_url)  # Pass the stored MP3 URL to Whisper
    p 'creating video'
    generate_video(subtitles)  # Generate video with the obtained
  end



  private

  def generate_video(subtitles)
        # subtitles = [{"word"=>"Moving", "start"=>0.0, "end"=>0.41999998688697815}, {"word"=>"down", "start"=>0.41999998688697815, "end"=>0.7200000286102295}, {"word"=>"to", "start"=>0.7200000286102295, "end"=>0.8399999737739563}, {"word"=>"the", "start"=>0.8399999737739563, "end"=>1.0}, {"word"=>"central", "start"=>1.0, "end"=>1.2999999523162842}, {"word"=>"area", "start"=>1.2999999523162842, "end"=>1.559999942779541}, {"word"=>"we", "start"=>1.559999942779541, "end"=>1.8200000524520874}, {"word"=>"are", "start"=>1.8200000524520874, "end"=>2.0399999618530273}, {"word"=>"seeing", "start"=>2.0399999618530273, "end"=>2.180000066757202}, {"word"=>"clear", "start"=>2.180000066757202, "end"=>2.5399999618530273}, {"word"=>"skies", "start"=>2.5399999618530273, "end"=>2.940000057220459}, {"word"=>"a", "start"=>3.380000114440918, "end"=>3.4800000190734863}, {"word"=>"gentle", "start"=>3.4800000190734863, "end"=>3.640000104904175}, {"word"=>"breeze", "start"=>3.640000104904175, "end"=>3.940000057220459}, {"word"=>"and", "start"=>3.940000057220459, "end"=>4.139999866485596}, {"word"=>"mild", "start"=>4.139999866485596, "end"=>4.380000114440918}, {"word"=>"temperatures", "start"=>4.380000114440918, "end"=>4.840000152587891}, {"word"=>"perfect", "start"=>5.440000057220459, "end"=>5.440000057220459}, {"word"=>"for", "start"=>5.440000057220459, "end"=>5.639999866485596}, {"word"=>"an", "start"=>5.639999866485596, "end"=>5.840000152587891}, {"word"=>"evening", "start"=>5.840000152587891, "end"=>6.039999961853027}, {"word"=>"stroll", "start"=>6.039999961853027, "end"=>6.820000171661377}, {"word"=>"Temperatures", "start"=>7.239999771118164, "end"=>7.420000076293945}, {"word"=>"are", "start"=>7.420000076293945, "end"=>7.71999979019165}, {"word"=>"hovering", "start"=>7.71999979019165, "end"=>7.920000076293945}, {"word"=>"around", "start"=>7.920000076293945, "end"=>8.260000228881836}, {"word"=>"a", "start"=>8.260000228881836, "end"=>8.4399995803833}, {"word"=>"comfortable", "start"=>8.4399995803833, "end"=>8.699999809265137}, {"word"=>"55", "start"=>8.699999809265137, "end"=>9.399999618530273}, {"word"=>"degrees", "start"=>9.399999618530273, "end"=>9.84000015258789}, {"word"=>"Fahrenheit", "start"=>9.84000015258789, "end"=>10.300000190734863}, {"word"=>"the", "start"=>10.619999885559082, "end"=>10.800000190734863}, {"word"=>"ideal", "start"=>10.800000190734863, "end"=>11.140000343322754}, {"word"=>"weather", "start"=>11.140000343322754, "end"=>11.399999618530273}, {"word"=>"for", "start"=>11.399999618530273, "end"=>11.680000305175781}, {"word"=>"outdoor", "start"=>11.680000305175781, "end"=>12.0}, {"word"=>"activities", "start"=>12.0, "end"=>12.5}]
    last_word_endtime = subtitles.last['end'].to_f
    css = "p { font-family: \"Lato\"; color: #ffffff; font-size: 60px; text-align: center; font-weight: bold;    }"
    sub_clips = subtitles.map do |subtitle|

      length = subtitle['end'].to_f - subtitle['start'].to_f
      {
        "asset": {
            "type": "html",
            "html": "<p>#{subtitle['text']}</p>",
            "css": css
        },
        "start": subtitle['start'].to_f,
        "length": length

      }
    end
    vid_clips = [{
      "asset": {
          "type": "video",
          "src": @source_url,
          "volume": 0
      },
      "start": 0,
      "length": last_word_endtime + 1,
      "transition": {
          "out": "fade"
      }
    }]

    result = {
      "timeline": {
        "soundtrack": {
          "src": @mp3_url,
          "effect": "fadeOut"
      },
      "background": "#000000",
      "tracks": [
          {
              "clips": sub_clips
          },
          {
            "clips": vid_clips
          }
        ]
      },
      "output": {
        "format": "mp4",
        "resolution": "hd",
        "aspectRatio": "9:16"
      }
    }

    create_video = RestClient.post( "https://api.shotstack.io/edit/stage/render",
    result.to_json, @headers)

    video_response = JSON.parse(create_video)
    video_id = video_response['response']['id']

    get_video = JSON.parse(RestClient.get( "https://api.shotstack.io/edit/stage/render/#{video_id}", @headers))
    while get_video['response']['status'] != 'done'
    get_video = JSON.parse(RestClient.get( "https://api.shotstack.io/edit/stage/render/#{video_id}", @headers))
      p get_video['response']['status']
      sleep 2
      p 'processing video....'
      if get_video['response']['status'] == 'done'
        edited_video_url = get_video['response']['url']
        p edited_video_url
        return edited_video_url
      end
    end
  end

  def call_whisper(mp3_url)
    #Download the mp3 file get mp3 from shortstack api
    #mp3_url = "https://shotstack-create-api-stage-assets.s3.amazonaws.com/zdwo0ydyi8/01hyf-pwten-spw2h-5w91h-s75vz2.mp3"
    mp3_data = URI.open(mp3_url).read

    # Write mp3 data to a temporary file
    Tempfile.create(['audio', '.mp3'], encoding: 'binary') do |file|
      file.binmode # Ensure the file is in binary mode
      file.write(mp3_data)
      file.rewind

      # Transcribe audio file using OpenAI's API
      response = @client.audio.transcribe(
        parameters: {
          model: "whisper-1",
          file: file,
          language: "en", # Optional
          transcription: 'srt',
          timestamp_granularities: ['segment'],
          response_format: 'verbose_json'
        }
      )

      # Print the transcribed text
      subtitles = response['segments']
      return subtitles

    end
  end

  def create_mp3(script)

    result_audio = RestClient.post('https://api.shotstack.io/create/stage/assets',
    {
      "provider": "shotstack",
      "options": {
        "type": "text-to-speech",
        "text": script,
        "voice": "Matthew",
        "language": "en-US",
        "newscaster": false
      }
    }.to_json, @headers)

    audio_response = JSON.parse(result_audio)
    p audio_id = audio_response['data']['id']
    sleep 5
    result = RestClient.get "https://api.shotstack.io/create/stage/assets/#{audio_id}",
    @headers
    result_mp3 = JSON.parse(result)
    p mp3_url = result_mp3['data']['attributes']['url']
    return mp3_url
  end


end
