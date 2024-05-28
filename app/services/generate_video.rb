# app/services/openai_service.rb
require "openai"
require 'open-uri'
require 'base64'
require 'tempfile'
require "json"
require 'rest-client'

class GenerateVideo
  attr_reader :mp3_url, :subtitles

  def initialize(source_url, script)
    @source_url = source_url
    @script = script
    @client = OpenAI::Client.new(
      access_token: ENV['OPENAI_ACCESS_TOKEN'],
      log_errors: true # Highly recommended in development, so you can see what errors OpenAI is returning. Not recommended in production.
    )
    @headers = {
      'Content-Type' => 'application/json',
      'Accept' => 'application/json',
      'x-api-key' => ENV['SHOTSTACK_API']
      }
    @mp3_url = 'https://shotstack-create-api-stage-assets.s3.amazonaws.com/tao11s6mke/01hyw-a53dg-k8tx6-v8bh2-8qjz84.mp3'
    # sample mp3'https://shotstack-create-api-stage-assets.s3.amazonaws.com/tao11s6mke/01hyw-a53dg-k8tx6-v8bh2-8qjz84.mp3'
    @subtitles = [{"id"=>0, "seek"=>0, "start"=>0.0, "end"=>2.559999942779541, "text"=>" Hello, how are you? Bye.", "tokens"=>[50364, 2425, 11, 577, 366, 291, 30, 4621, 13, 50492], "temperature"=>0.0, "avg_logprob"=>-0.553535521030426, "compression_ratio"=>0.75, "no_speech_prob"=>0.00023138776305131614}]
    # sample subs[{"id"=>0, "seek"=>0, "start"=>0.0, "end"=>2.559999942779541, "text"=>" Hello, how are you? Bye.", "tokens"=>[50364, 2425, 11, 577, 366, 291, 30, 4621, 13, 50492], "temperature"=>0.0, "avg_logprob"=>-0.553535521030426, "compression_ratio"=>0.75, "no_speech_prob"=>0.00023138776305131614}]
  end
  def final_video_link
    p 'creating mp3'
    # @mp3_url = create_mp3(@script)  # Ensure MP3 is created first and the URL is stored
    # p 'creating subtitle'
    # @subtitles = call_whisper(@mp3_url)  # Pass the stored MP3 URL to Whisper
    p 'creating video'
    generate_video(@subtitles)  # Generate video with the obtained
  end

  # start_time += time_per_word
  private

  def generate_video(subtitles)

    last_word_endtime = subtitles.last['end'].to_f
    css = "span { background: white; font-family: \"Lato\"; font-size: 60px;color: #000000;font-weight: bold;font-style: normal;text-decoration: none;line-height: 200;padding: 10;}"

    #"p { font-family: \"Lato\"; color: #ffffff; font-size: 60px; text-align: center; font-weight: bold;    }"
    # word_split = subtitles.first['text'].split
    segment_clips = subtitles.map do |subtitle|
      start = subtitle['start'].to_f
      words = subtitle['text'].split
      total_letter_count = subtitle['text'].length
      total_time = subtitle['end'].to_f - subtitle['start'].to_f

        word_clips = words.map do |word|
          # length = subtitle['end'].to_f - subtitle['start'].to_f
          length_word = ((word.length.to_f + 1)/ total_letter_count) * total_time
          body = {
            "asset": {
              "type": "html",
              # "html": "<p>#{subtitle['text']}</p>",
              # "html": "<span class='text'>#{word.upcase}</span>",
              "html": "<table border='\''0'\''><tr><td><h1>#{word.upcase}</h1></td></tr></table>",
              # "css": ".text { padding: 50px; background-color: #2175d9; line-height: 60px;font-size: 60px; color: #FFFFFF; font-family: \"Rubik Mono One\"; }"
              # "html": "<span>#{word.upcase}</span>",
              # "css": "span { font-family: 'Indie Flower'; color: #80ffffff; font-size: 60px ;}",
              #"css": "span { font-family: 'Montserrat ExtraBold'; color: #80000000; font-size: 60px ;background-color: #80000000;}",
              # "height": 60,
              # "background": "#80ffffff"
              # "css": "span { font-family: 'Montserrat ExtraBold'; color: #ffffff; font-size: 60px; text-align: center; }",
              "css": "table { background-color: #000000; } td { padding-top: 10px; padding-bottom: 10px; } h1 { color: #FFFFFF; font-size: 34px; font-family: '\''Open Sans'\''; font-weight: bold; margin: 60px; text-align: center; }",
              "width": 300,
              # "html": "<table cellpadding='\''16'\''><tr><td><p>#{word.upcase}</p></td></tr></table>",
              # "css": "table { background-color: #33000000; } p { color: #FFFFFF; font-size: 100px; font-family: '\''Open Sans'\'' }",
              # "position": "center",
              "height": 100
            },
            "start": start,
            "length": length_word,
            # "position": "center",
          #   "transition": {
          #                   "in": "fade",
          #                   "out": "fade"
          # }

          }
          start += length_word
          body

      end
    end
    # segment2_clips = subtitles.map do |subtitle|
    #   start = subtitle['start'].to_f
    #   words = subtitle['text'].split
    #   total_letter_count = subtitle['text'].length
    #   total_time = subtitle['end'].to_f - subtitle['start'].to_f

    #     word_clips = words.map do |word|
    #       # length = subtitle['end'].to_f - subtitle['start'].to_f
    #       length_word = ((word.length.to_f + 1)/ total_letter_count) * total_time
    #       blur_body = {
    #               "asset": {
    #                 "type": "html",
    #                 # "html": "<p>#{subtitle['text']}</p>",
    #                 # "html": "<span class='text'>#{word.upcase}</span>",
    #                 # "css": ".text { padding: 50px; background-color: #2175d9; line-height: 200px;font-size: 60px; color: #FFFFFF; font-family: \"Rubik Mono One\"; }"
    #                 "css": "span { font-family: 'Montserrat ExtraBold'; color: #000000; font-size: 60px; text-align: center; }",
    #               },
    #               "start": start,
    #               "length": length_word,
    #               "offset": {
    #                 "x": 0.005,
    #                 "y": -0.005
    #             }
    #             }
    #       start += length_word
    #       blur_body
    #     end
    #  end
    #end of loop for the text header
    # p segment_clips
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

#body for the api request
    result = {
      "timeline": {
        "soundtrack": {
          "src": @mp3_url,
          "effect": "fadeOut"
      },

      "background": "#000000",
      "fonts": [
        {
            "src": "https://drive.google.com/uc?export=download&id=1D8p_OymO_DrnELh-V9fmKtWd14zr7CZH"
            # "src": "https://drive.google.com/uc?export=download&id=1H0ngg6u4uU2kA5ewsNqcJWzyi8VPJq1T"
            #"src": "https://drive.google.com/uc?export=download&id=1LuLfTcGJt-A1sCQ55iCEI4042XlrOHWM"
        },
        {
            "src": "https://shotstack-assets.s3-ap-southeast-2.amazonaws.com/fonts/OpenSans-Regular.ttf"
        },
        {
            "src": "https://shotstack-assets.s3-ap-southeast-2.amazonaws.com/fonts/IndieFlower-Regular.ttf"
        }
      ],
      "tracks": [
          {
              "clips": segment_clips.flatten
          },
          # {
          #     "clips": segment2_clips.flatten
          # },
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
    p result.to_json
        create_video = RestClient.post("https://api.shotstack.io/edit/stage/render",
    result.to_json, @headers)

    p create_video
    video_response = JSON.parse(create_video)
    video_id = video_response['response']['id']
    p start_process = Time.now
    get_video = JSON.parse(RestClient.get("https://api.shotstack.io/edit/stage/render/#{video_id}", @headers))
    while get_video['response']['status'] != 'done'
    get_video = JSON.parse(RestClient.get("https://api.shotstack.io/edit/stage/render/#{video_id}", @headers))
      p get_video['response']['status']
      sleep 2
      p 'processing video....'
      if get_video['response']['status'] == 'done'
        edited_video_url = get_video['response']['url']
        p edited_video_url
        start_process - Time.now
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
      p subtitles = response['segments']
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
    result = JSON.parse(RestClient.get("https://api.shotstack.io/create/stage/assets/#{audio_id}",
    @headers))
    status = result['data']['attributes']['status']
    if status == 'done'
      return mp3_url = result['data']['attributes']['url']
    else
      while status != 'done'
        result = JSON.parse(RestClient.get("https://api.shotstack.io/create/stage/assets/#{audio_id}", @headers))
          p status
          sleep 2
          p 'processing speech result....'
          if status == 'done'
            mp3_url = result['data']['attributes']['url']
            p mp3_url
            return mp3_url
          end
        end
      end
    # result_mp3 = JSON.parse(result)
    # p mp3_url = result_mp3['data']['attributes']['url']
    # return mp3_url
  end


end
