require "openai"
require 'open-uri'
require 'base64'
require 'tempfile'
require "json"
require 'rest-client'

class GenerateVideoV1
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
    @mp3_url = 'https://drive.google.com/uc?export=download&id=1QKH2UREKnC87lcTrg2yr5Nczt3ZhNC5l'
    @subtitles = [{"word"=>"really", "start"=>0.0, "end"=>0.30000001192092896}, {"word"=>"quiet", "start"=>0.30000001192092896, "end"=>0.6600000262260437}, {"word"=>"soft", "start"=>0.8999999761581421, "end"=>1.2000000476837158}, {"word"=>"spoken", "start"=>1.2000000476837158, "end"=>1.4800000190734863}, {"word"=>"polite", "start"=>1.9800000190734863, "end"=>2.0199999809265137}, {"word"=>"guy", "start"=>2.0199999809265137, "end"=>2.3399999141693115}, {"word"=>"a", "start"=>2.8399999141693115, "end"=>2.940000057220459}, {"word"=>"total", "start"=>2.940000057220459, "end"=>3.200000047683716}, {"word"=>"gentleman", "start"=>3.200000047683716, "end"=>3.5799999237060547}, {"word"=>"and", "start"=>3.5799999237060547, "end"=>3.859999895095825}, {"word"=>"a", "start"=>3.859999895095825, "end"=>4.199999809265137}, {"word"=>"graduate", "start"=>4.199999809265137, "end"=>4.340000152587891}, {"word"=>"student", "start"=>4.340000152587891, "end"=>4.699999809265137}, {"word"=>"in", "start"=>4.699999809265137, "end"=>4.840000152587891}, {"word"=>"the", "start"=>4.840000152587891, "end"=>5.019999980926514}, {"word"=>"liberal", "start"=>5.019999980926514, "end"=>5.21999979019165}, {"word"=>"arts", "start"=>5.21999979019165, "end"=>5.539999961853027}, {"word"=>"Also", "start"=>6.440000057220459, "end"=>6.559999942779541}, {"word"=>"pretty", "start"=>6.920000076293945, "end"=>7.059999942779541}, {"word"=>"inexperienced", "start"=>7.059999942779541, "end"=>7.739999771118164}, {"word"=>"tentative", "start"=>8.300000190734863, "end"=>8.5}, {"word"=>"and", "start"=>8.720000267028809, "end"=>8.9399995803833}, {"word"=>"vanilla", "start"=>8.9399995803833, "end"=>9.220000267028809}, {"word"=>"sexually", "start"=>9.220000267028809, "end"=>9.84000015258789}, {"word"=>"He's", "start"=>10.899999618530273, "end"=>11.079999923706055}, {"word"=>"dating", "start"=>11.079999923706055, "end"=>11.220000267028809}, {"word"=>"this", "start"=>11.220000267028809, "end"=>11.420000076293945}, {"word"=>"really", "start"=>11.420000076293945, "end"=>11.760000228881836}, {"word"=>"cool", "start"=>11.760000228881836, "end"=>11.880000114440918}, {"word"=>"girl", "start"=>11.880000114440918, "end"=>12.079999923706055}, {"word"=>"for", "start"=>12.079999923706055, "end"=>12.319999694824219}, {"word"=>"maybe", "start"=>12.319999694824219, "end"=>12.5600004196167}, {"word"=>"two", "start"=>12.5600004196167, "end"=>12.779999732971191}, {"word"=>"months", "start"=>12.779999732971191, "end"=>13.0600004196167}, {"word"=>"she", "start"=>13.479999542236328, "end"=>13.579999923706055}, {"word"=>"is", "start"=>13.579999923706055, "end"=>13.760000228881836}, {"word"=>"much", "start"=>13.760000228881836, "end"=>13.979999542236328}, {"word"=>"kinkier", "start"=>13.979999542236328, "end"=>14.300000190734863}, {"word"=>"in", "start"=>14.300000190734863, "end"=>14.800000190734863}, {"word"=>"bed", "start"=>14.800000190734863, "end"=>14.800000190734863}, {"word"=>"she", "start"=>15.140000343322754, "end"=>15.520000457763672}, {"word"=>"floats", "start"=>15.520000457763672, "end"=>15.520000457763672}, {"word"=>"the", "start"=>15.520000457763672, "end"=>15.739999771118164}, {"word"=>"idea", "start"=>15.739999771118164, "end"=>15.899999618530273}, {"word"=>"of", "start"=>15.899999618530273, "end"=>16.079999923706055}, {"word"=>"dirty", "start"=>16.079999923706055, "end"=>16.280000686645508}, {"word"=>"talk", "start"=>16.280000686645508, "end"=>16.579999923706055}, {"word"=>"and", "start"=>16.579999923706055, "end"=>16.760000228881836}, {"word"=>"apparently", "start"=>16.760000228881836, "end"=>17.139999389648438}, {"word"=>"likes", "start"=>17.139999389648438, "end"=>17.3799991607666}, {"word"=>"to", "start"=>17.3799991607666, "end"=>17.520000457763672}, {"word"=>"be", "start"=>17.520000457763672, "end"=>17.68000030517578}, {"word"=>"objectified", "start"=>17.68000030517578, "end"=>18.239999771118164}, {"word"=>"from", "start"=>18.239999771118164, "end"=>18.520000457763672}, {"word"=>"time", "start"=>18.520000457763672, "end"=>18.739999771118164}, {"word"=>"to", "start"=>18.739999771118164, "end"=>18.959999084472656}, {"word"=>"time", "start"=>18.959999084472656, "end"=>19.18000030517578}, {"word"=>"He's", "start"=>19.760000228881836, "end"=>20.100000381469727}, {"word"=>"hesitant", "start"=>20.100000381469727, "end"=>20.280000686645508}, {"word"=>"but", "start"=>20.280000686645508, "end"=>20.600000381469727}, {"word"=>"wants", "start"=>20.600000381469727, "end"=>20.799999237060547}, {"word"=>"to", "start"=>20.799999237060547, "end"=>21.18000030517578}, {"word"=>"please", "start"=>21.18000030517578, "end"=>21.239999771118164}, {"word"=>"her", "start"=>21.239999771118164, "end"=>21.360000610351562}, {"word"=>"and", "start"=>21.360000610351562, "end"=>21.579999923706055}, {"word"=>"doesn't", "start"=>21.579999923706055, "end"=>21.780000686645508}, {"word"=>"dismiss", "start"=>21.780000686645508, "end"=>22.079999923706055}, {"word"=>"the", "start"=>22.079999923706055, "end"=>22.559999465942383}, {"word"=>"idea", "start"=>22.559999465942383, "end"=>22.559999465942383}, {"word"=>"outright", "start"=>22.559999465942383, "end"=>22.959999084472656}, {"word"=>"changes", "start"=>23.639999389648438, "end"=>23.639999389648438}, {"word"=>"the", "start"=>23.639999389648438, "end"=>23.920000076293945}, {"word"=>"subject", "start"=>23.920000076293945, "end"=>24.18000030517578}, {"word"=>"and", "start"=>24.18000030517578, "end"=>24.559999465942383}, {"word"=>"figures", "start"=>24.559999465942383, "end"=>24.700000762939453}, {"word"=>"that", "start"=>24.700000762939453, "end"=>24.899999618530273}, {"word"=>"they'll", "start"=>24.899999618530273, "end"=>25.1200008392334}, {"word"=>"revisit", "start"=>25.1200008392334, "end"=>25.479999542236328}, {"word"=>"the", "start"=>25.479999542236328, "end"=>26.020000457763672}, {"word"=>"idea", "start"=>26.020000457763672, "end"=>26.020000457763672}, {"word"=>"another", "start"=>26.020000457763672, "end"=>26.3799991607666}, {"word"=>"time", "start"=>26.3799991607666, "end"=>26.719999313354492}, {"word"=>"Anyway", "start"=>27.760000228881836, "end"=>28.18000030517578}, {"word"=>"they", "start"=>28.579999923706055, "end"=>28.639999389648438}, {"word"=>"have", "start"=>28.639999389648438, "end"=>28.940000534057617}, {"word"=>"sex", "start"=>28.940000534057617, "end"=>29.1200008392334}, {"word"=>"a", "start"=>29.1200008392334, "end"=>29.280000686645508}, {"word"=>"few", "start"=>29.280000686645508, "end"=>29.5}, {"word"=>"days", "start"=>29.5, "end"=>29.700000762939453}, {"word"=>"later", "start"=>29.700000762939453, "end"=>29.959999084472656}, {"word"=>"for", "start"=>29.959999084472656, "end"=>30.139999389648438}, {"word"=>"the", "start"=>30.139999389648438, "end"=>30.299999237060547}, {"word"=>"first", "start"=>30.299999237060547, "end"=>30.540000915527344}, {"word"=>"time", "start"=>30.540000915527344, "end"=>30.8799991607666}, {"word"=>"since", "start"=>30.8799991607666, "end"=>31.059999465942383}, {"word"=>"the", "start"=>31.059999465942383, "end"=>31.280000686645508}, {"word"=>"conversation", "start"=>31.280000686645508, "end"=>31.760000228881836}, {"word"=>"really", "start"=>32.439998626708984, "end"=>32.720001220703125}, {"word"=>"going", "start"=>32.720001220703125, "end"=>32.91999816894531}, {"word"=>"at", "start"=>32.91999816894531, "end"=>33.08000183105469}, {"word"=>"it", "start"=>33.08000183105469, "end"=>33.2400016784668}, {"word"=>"doggy", "start"=>33.2400016784668, "end"=>33.52000045776367}, {"word"=>"style", "start"=>33.52000045776367, "end"=>33.7400016784668}, {"word"=>"and", "start"=>34.099998474121094, "end"=>34.220001220703125}, {"word"=>"she", "start"=>34.220001220703125, "end"=>34.34000015258789}, {"word"=>"tells", "start"=>34.34000015258789, "end"=>34.58000183105469}, {"word"=>"him", "start"=>34.58000183105469, "end"=>34.65999984741211}, {"word"=>"to", "start"=>34.65999984741211, "end"=>34.86000061035156}, {"word"=>"talk", "start"=>34.86000061035156, "end"=>35.08000183105469}, {"word"=>"dirty", "start"=>35.08000183105469, "end"=>35.34000015258789}, {"word"=>"to", "start"=>35.34000015258789, "end"=>35.599998474121094}, {"word"=>"her", "start"=>35.599998474121094, "end"=>35.720001220703125}, {"word"=>"He", "start"=>36.34000015258789, "end"=>36.52000045776367}, {"word"=>"says", "start"=>36.52000045776367, "end"=>36.70000076293945}, {"word"=>"that", "start"=>36.70000076293945, "end"=>36.84000015258789}, {"word"=>"he", "start"=>36.84000015258789, "end"=>36.959999084472656}, {"word"=>"can't", "start"=>36.959999084472656, "end"=>37.20000076293945}, {"word"=>"think", "start"=>37.20000076293945, "end"=>37.31999969482422}, {"word"=>"of", "start"=>37.31999969482422, "end"=>37.540000915527344}, {"word"=>"anything", "start"=>37.540000915527344, "end"=>37.65999984741211}, {"word"=>"to", "start"=>37.65999984741211, "end"=>38.13999938964844}, {"word"=>"say", "start"=>38.13999938964844, "end"=>38.13999938964844}, {"word"=>"so", "start"=>38.439998626708984, "end"=>38.619998931884766}, {"word"=>"he", "start"=>38.619998931884766, "end"=>38.7599983215332}, {"word"=>"says", "start"=>38.7599983215332, "end"=>38.91999816894531}, {"word"=>"nothing", "start"=>38.91999816894531, "end"=>39.2599983215332}, {"word"=>"and", "start"=>39.560001373291016, "end"=>39.959999084472656}, {"word"=>"she", "start"=>39.959999084472656, "end"=>40.08000183105469}, {"word"=>"then", "start"=>40.08000183105469, "end"=>40.400001525878906}, {"word"=>"repeats", "start"=>40.400001525878906, "end"=>40.560001373291016}, {"word"=>"the", "start"=>40.560001373291016, "end"=>40.79999923706055}, {"word"=>"request", "start"=>40.79999923706055, "end"=>41.119998931884766}, {"word"=>"but", "start"=>41.52000045776367, "end"=>41.599998474121094}, {"word"=>"the", "start"=>41.599998474121094, "end"=>41.7599983215332}, {"word"=>"second", "start"=>41.7599983215332, "end"=>41.959999084472656}, {"word"=>"time", "start"=>41.959999084472656, "end"=>42.20000076293945}, {"word"=>"she", "start"=>42.20000076293945, "end"=>42.380001068115234}, {"word"=>"is", "start"=>42.380001068115234, "end"=>42.540000915527344}, {"word"=>"not", "start"=>42.540000915527344, "end"=>42.7400016784668}, {"word"=>"fucking", "start"=>42.7400016784668, "end"=>43.060001373291016}, {"word"=>"requesting", "start"=>43.060001373291016, "end"=>43.459999084472656}, {"word"=>"but", "start"=>43.459999084472656, "end"=>43.939998626708984}, {"word"=>"demanding", "start"=>43.939998626708984, "end"=>44.2599983215332}, {"word"=>"it", "start"=>44.2599983215332, "end"=>44.52000045776367}, {"word"=>"He", "start"=>44.599998474121094, "end"=>45.2599983215332}, {"word"=>"comes", "start"=>45.2599983215332, "end"=>45.459999084472656}, {"word"=>"up", "start"=>45.459999084472656, "end"=>45.68000030517578}, {"word"=>"with", "start"=>45.68000030517578, "end"=>46.13999938964844}, {"word"=>"yeah", "start"=>46.400001525878906, "end"=>46.63999938964844}, {"word"=>"you", "start"=>46.86000061035156, "end"=>47.279998779296875}, {"word"=>"like", "start"=>47.279998779296875, "end"=>47.52000045776367}, {"word"=>"that", "start"=>47.52000045776367, "end"=>47.79999923706055}, {"word"=>"you", "start"=>47.939998626708984, "end"=>48.08000183105469}, {"word"=>"fucking", "start"=>48.08000183105469, "end"=>48.380001068115234}, {"word"=>"retard", "start"=>48.380001068115234, "end"=>48.779998779296875}, {"word"=>"He's", "start"=>49.060001373291016, "end"=>49.5}, {"word"=>"never", "start"=>49.5, "end"=>49.70000076293945}, {"word"=>"as", "start"=>49.70000076293945, "end"=>50.119998931884766}, {"word"=>"one", "start"=>50.119998931884766, "end"=>50.41999816894531}, {"word"=>"for", "start"=>50.41999816894531, "end"=>50.86000061035156}, {"word"=>"embellishment", "start"=>50.86000061035156, "end"=>51.29999923706055}, {"word"=>"so", "start"=>51.81999969482422, "end"=>51.91999816894531}, {"word"=>"I", "start"=>51.91999816894531, "end"=>52.119998931884766}, {"word"=>"believe", "start"=>52.119998931884766, "end"=>52.34000015258789}, {"word"=>"him", "start"=>52.34000015258789, "end"=>52.58000183105469}, {"word"=>"He", "start"=>53.2599983215332, "end"=>53.41999816894531}, {"word"=>"said", "start"=>53.41999816894531, "end"=>53.560001373291016}, {"word"=>"that", "start"=>53.560001373291016, "end"=>53.7400016784668}, {"word"=>"was", "start"=>53.7400016784668, "end"=>53.880001068115234}, {"word"=>"it", "start"=>53.880001068115234, "end"=>54.040000915527344}, {"word"=>"for", "start"=>54.040000915527344, "end"=>54.2400016784668}, {"word"=>"sex", "start"=>54.2400016784668, "end"=>54.47999954223633}, {"word"=>"that", "start"=>54.47999954223633, "end"=>54.70000076293945}, {"word"=>"night", "start"=>54.70000076293945, "end"=>54.939998626708984}, {"word"=>"although", "start"=>55.36000061035156, "end"=>55.439998626708984}, {"word"=>"they", "start"=>55.439998626708984, "end"=>55.619998931884766}, {"word"=>"are", "start"=>55.619998931884766, "end"=>55.86000061035156}, {"word"=>"still", "start"=>55.86000061035156, "end"=>56.13999938964844}, {"word"=>"together", "start"=>56.13999938964844, "end"=>56.400001525878906}, {"word"=>"two", "start"=>56.400001525878906, "end"=>56.720001220703125}, {"word"=>"years", "start"=>56.720001220703125, "end"=>56.900001525878906}, {"word"=>"on", "start"=>56.900001525878906, "end"=>57.18000030517578}, {"word"=>"now", "start"=>57.18000030517578, "end"=>57.400001525878906}]
  end

  def final_video_link
    # p 'creating mp3'
    # @mp3_url = create_mp3(@script)  # Ensure MP3 is created first and the URL is stored
    # p 'creating subtitle'
    # subtitles = call_whisper(@mp3_url)  # Pass the stored MP3 URL to Whisper
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
            "html": "<p>#{subtitle['word']}</p>",
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
          timestamp_granularities: ['word'],
          response_format: 'verbose_json'
        }
      )

      # Print the transcribed text
      p subtitles = response['words']
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
    result = RestClient.get "https://api.shotstack.io/create/stage/assets/#{audio_id}",
    @headers
    p start_process = Time.now
    while result['data']['attributes']['status'] != 'done'
      result = JSON.parse(RestClient.get("https://api.shotstack.io/create/stage/assets/#{audio_id}", @headers))
        p result['data']['attributes']['status']
        sleep 2
        p 'processing speech mp3....'
        if result['data']['attributes']['status'] == 'done'
          mp3_url = mp3['data']['attributes']['url']
          p mp3_url
          return mp3_url
        end
    end
  end
end
