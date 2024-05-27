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
    @mp3_url = ''
    # sample mp3'https://shotstack-create-api-stage-assets.s3.amazonaws.com/tao11s6mke/01hyw-a53dg-k8tx6-v8bh2-8qjz84.mp3'
    @subtitles = ''
    # sample subs[{"id"=>0, "seek"=>0, "start"=>0.0, "end"=>2.559999942779541, "text"=>" Hello, how are you? Bye.", "tokens"=>[50364, 2425, 11, 577, 366, 291, 30, 4621, 13, 50492], "temperature"=>0.0, "avg_logprob"=>-0.553535521030426, "compression_ratio"=>0.75, "no_speech_prob"=>0.00023138776305131614}]
  end
  def final_video_link
    p 'creating mp3'
    @mp3_url = create_mp3(@script)  # Ensure MP3 is created first and the URL is stored
    p 'creating subtitle'
    @subtitles = call_whisper(@mp3_url)  # Pass the stored MP3 URL to Whisper
    p 'creating video'
    generate_video(@subtitles)  # Generate video with the obtained
  end

  # start_time += time_per_word
  private

  def generate_video(subtitles)
        # subtitles = [{"word"=>"Moving", "start"=>0.0, "end"=>0.41999998688697815}, {"word"=>"down", "start"=>0.41999998688697815, "end"=>0.7200000286102295}, {"word"=>"to", "start"=>0.7200000286102295, "end"=>0.8399999737739563}, {"word"=>"the", "start"=>0.8399999737739563, "end"=>1.0}, {"word"=>"central", "start"=>1.0, "end"=>1.2999999523162842}, {"word"=>"area", "start"=>1.2999999523162842, "end"=>1.559999942779541}, {"word"=>"we", "start"=>1.559999942779541, "end"=>1.8200000524520874}, {"word"=>"are", "start"=>1.8200000524520874, "end"=>2.0399999618530273}, {"word"=>"seeing", "start"=>2.0399999618530273, "end"=>2.180000066757202}, {"word"=>"clear", "start"=>2.180000066757202, "end"=>2.5399999618530273}, {"word"=>"skies", "start"=>2.5399999618530273, "end"=>2.940000057220459}, {"word"=>"a", "start"=>3.380000114440918, "end"=>3.4800000190734863}, {"word"=>"gentle", "start"=>3.4800000190734863, "end"=>3.640000104904175}, {"word"=>"breeze", "start"=>3.640000104904175, "end"=>3.940000057220459}, {"word"=>"and", "start"=>3.940000057220459, "end"=>4.139999866485596}, {"word"=>"mild", "start"=>4.139999866485596, "end"=>4.380000114440918}, {"word"=>"temperatures", "start"=>4.380000114440918, "end"=>4.840000152587891}, {"word"=>"perfect", "start"=>5.440000057220459, "end"=>5.440000057220459}, {"word"=>"for", "start"=>5.440000057220459, "end"=>5.639999866485596}, {"word"=>"an", "start"=>5.639999866485596, "end"=>5.840000152587891}, {"word"=>"evening", "start"=>5.840000152587891, "end"=>6.039999961853027}, {"word"=>"stroll", "start"=>6.039999961853027, "end"=>6.820000171661377}, {"word"=>"Temperatures", "start"=>7.239999771118164, "end"=>7.420000076293945}, {"word"=>"are", "start"=>7.420000076293945, "end"=>7.71999979019165}, {"word"=>"hovering", "start"=>7.71999979019165, "end"=>7.920000076293945}, {"word"=>"around", "start"=>7.920000076293945, "end"=>8.260000228881836}, {"word"=>"a", "start"=>8.260000228881836, "end"=>8.4399995803833}, {"word"=>"comfortable", "start"=>8.4399995803833, "end"=>8.699999809265137}, {"word"=>"55", "start"=>8.699999809265137, "end"=>9.399999618530273}, {"word"=>"degrees", "start"=>9.399999618530273, "end"=>9.84000015258789}, {"word"=>"Fahrenheit", "start"=>9.84000015258789, "end"=>10.300000190734863}, {"word"=>"the", "start"=>10.619999885559082, "end"=>10.800000190734863}, {"word"=>"ideal", "start"=>10.800000190734863, "end"=>11.140000343322754}, {"word"=>"weather", "start"=>11.140000343322754, "end"=>11.399999618530273}, {"word"=>"for", "start"=>11.399999618530273, "end"=>11.680000305175781}, {"word"=>"outdoor", "start"=>11.680000305175781, "end"=>12.0}, {"word"=>"activities", "start"=>12.0, "end"=>12.5}]
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
              "html": "<span class='text'>#{word.upcase}</span>",
              "css": ".text { padding: 50px; background-color: #2175d9; line-height: 200px;font-size: 60px; color: #FFFFFF; font-weight: 600;font-family: 'Bangers'; }",
              #  "<table>\n  <tr>\n    <td bgcolor=\"#2175d9\">\n          <img src=\"data:image/png;base64, iVBORw0KGgoAAAANSUhEUgAAAA8AAAAPCAIAAAC0tAIdAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAABxJREFUeNpiVCy9yUA0YGIgBYyqHlVNfdUAAQYABPQBjSXFZ0oAAAAASUVORK5CYII=\"/>\n          </td>\n    <td bgcolor=\"#2175d9\">&nbsp;</td>\n    <td>\n      <img src=\"data:image/png;base64, iVBORw0KGgoAAAANSUhEUgAAAA8AAAAPCAYAAAA71pVKAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAHxJREFUeNpiVCy9+Z8BAj4A8QUg3gjEG+53qz9gIAAYkTSjgwNAXAg05AIuzUx4DHYA4vNAw/uBWIBUzTBQAMT7sRlAjGYQMMBmALGasRpAimaYAfXkagaHAdB2A3I1g0A/oXgmBBTJtRkEAijR7E+JZgNKNAtQopkBIMAAqWEg7VTXSuIAAAAASUVORK5CYII=\"/>\n    </td>\n  </tr>\n  <tr>\n    <td bgcolor=\"#2175d9\">&nbsp;</td>\n    <td class=\"content\" bgcolor=\"#2175d9\">#{word}</td>\n    <td bgcolor=\"#2175d9\">&nbsp;</td>\n  </tr>\n  <tr>\n    <td>\n      <img src=\"data:image/png;base64, iVBORw0KGgoAAAANSUhEUgAAAA8AAAAPCAYAAAA71pVKAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAHZJREFUeNpiVCy9+Z+BTMDEQAEAaf5AieYLlGjeSInmDWRrvt+t/gBIH6AktAvJ1gy0HRRoEyiJ50ZSQ54RmQNMbQJAaj8QG5CsmVQDMJIn0P+gFOdITBgw4pMEugJkez8QO5CsGckQBSAVAMT+UO+AvMYAEGAAviIal7TNKnoAAAAASUVORK5CYII=\"/>\n    </td>\n    <td bgcolor=\"#2175d9\">&nbsp;</td>\n    <td>\n      <img src=\"data:image/png;base64, iVBORw0KGgoAAAANSUhEUgAAAA8AAAAPCAYAAAA71pVKAAAACXBIWXMAAAsSAAALEgHS3X78AAAAbklEQVQokWNULL35n4FMwESuRgYKNX+kRPMFSjRvGBDNB+91qT0gV3MBA5mhPfFel9oFcjRfZGBgaIBxSNEM0uhwr0vtA6maMTQSq3kiNo0gwIJH00FQqMICBxtA1vwRlORAkQ/CoHjE6x4GBgYA2i8hG289oyAAAAAASUVORK5CYII=\"/>\n    </td>\n  </tr>\n</table>",
              # "css": ".content { font-size: 60px; color: #FFFFFF; font-weight: 600; } td { font-size: 1px; vertical-align: middle; }",
              # "width": 400,
              # "height": 400
              # "html": "<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\n  <tr>\n    <td>\n      <img src=\"data:image/png;base64, iVBORw0KGgoAAAANSUhEUgAAAA8AAAAPCAYAAAA71pVKAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAHFJREFUeNpiYCAC/P//XwGIC4B4PxC//w8FhDQZQDVgBbg0CQBx/38CAJfG8/+JAGRrRNFMqkZ0zf3/SQSMsFAFUucZSARMULqfgQzACEoAQPo+OZpBNgcwkAlAmv3J1Qxy9nsgLUCu5v+UOJtsABBgAD84LB2rMDaKAAAAAElFTkSuQmCC\"/>\n    </td>\n    <td bgcolor=\"#FFFFFF\">&nbsp;</td>\n    <td>\n      <img src=\"data:image/png;base64, iVBORw0KGgoAAAANSUhEUgAAAA8AAAAPCAYAAAA71pVKAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAGJJREFUeNpi+I8A74F4PxAXALECAzHgP24AMsiAXM0w0A/EAuRqBoHzWA34TzzANOA/aQDVgP+kg35KNP+HxQITA3kAbDsjyBgyDVAk12YQCKDE5gOUaP5AiWYGSvzMABBgAI9IZJYHXKOcAAAAAElFTkSuQmCC\"/>\n    </td>\n  </tr>\n  <tr>\n    <td bgcolor=\"#FFFFFF\">&nbsp;</td>\n    <td class=\"content\" bgcolor=\"#FFFFFF\">{{whiteText}}</td>\n    <td bgcolor=\"#FFFFFF\">&nbsp;</td>\n  </tr>\n  <tr>\n    <td>\n      <img src=\"data:image/png;base64, iVBORw0KGgoAAAANSUhEUgAAAA8AAAAPCAYAAAA71pVKAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAG5JREFUeNpi/A8EDGQCJgYKAEjzB0o0X6BE80ZyNTMCw0sBSN8ny2ZGRsYHQPoAWTaDCKDtBkDqPFlRBbQdFGgTyI4zoO0CQHz+PwmAIgMocgE+L/STpRnJEAMg3k+WZiRDFIC4AGrQe5hmgAADAFo7+QIDpQviAAAAAElFTkSuQmCC\"/>\n    </td>\n    <td bgcolor=\"#FFFFFF\">&nbsp;</td>\n    <td bgcolor=\"#FFFFFF\">&nbsp;</td>\n  </tr>\n</table>",
              #               "css": ".content { padding: 5px 0 -5px 0; font-size: 60px; color: #2175d9; font-weight: 600; text-align: right; } td { font-size: 1px; vertical-align: middle; }",
            },
            "start": start,
            "length": length_word

          }
          start += length_word
          body
      end
    end
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
            "src": "https://drive.google.com/uc?export=download&id=1LuLfTcGJt-A1sCQ55iCEI4042XlrOHWM"
        }
      ],
      "tracks": [
          {
              "clips": segment_clips.flatten
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
