require 'open-uri'

class MostReplayed
  def initialize(url_id)
    @url = "https://yt.lemnoslife.com/videos?part=mostReplayed&id=#{url_id}"
    @sorted_scores = []
  end

  def get_response

    begin
      response_serialized = URI.open(@url).read
      response = JSON.parse(response_serialized)

      intensity_scores = response["items"][0]["mostReplayed"]["markers"].map do |marker|
        {
          startMillis: marker["startMillis"],
          intensityScoreNormalized: marker["intensityScoreNormalized"]
        }
      end

      @sorted_scores = intensity_scores.sort_by { |score| -score[:intensityScoreNormalized] }
    end

    write()
  end

  def write
    begin
      File.open("app/services/output.json", "w") do |file|
        file.write(JSON.pretty_generate(@sorted_scores))
      end

      # @sorted_scores.each do |score|
      #   puts "Timestamp: #{score[:startMillis]} ms - Intensity Score: #{score[:intensityScoreNormalized]}"
      # end
    rescue IOError => e
      puts "File Writing Error: #{e.message}"
    rescue StandardError => e
      puts "An error occurred: #{e.message}"
    end
  end
end
