require 'net/http'
require 'json'


    # An API key is defined here. You'd normally get this from the service you're accessing. It's a form of authentication.
    # This is the URL for the API endpoint we'll be making a GET request to.
    url = URI("https://api.elevenlabs.io/v1/models")

    # Here, headers for the HTTP request are being set up.
    # Headers provide metadata about the request. In this case, we're specifying the content type and including our API key for authentication.
    headers = {
      "Accept" => "application/json",
      "xi-api-key" => "73813942e4dcdf3f90d59f5e1bd206f9",
      "Content-Type" => "application/json"
    }

    # A GET request is sent to the API endpoint. The URL and the headers are passed into the request.
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(url)
    headers.each { |key, value| request[key] = value }
    response = http.request(request)

    # The JSON response from the API is parsed using the built-in JSON.parse method.
    # This transforms the JSON data into a Ruby hash for further processing.
    data = JSON.parse(response.body)

    # A loop is created to iterate over each 'voice' in the 'voices' list from the parsed data.
    # The 'voices' list consists of dictionaries, each representing a unique voice provided by the API.
    # data["voices"].each do |voice|
    #   # For each 'voice', the 'name' and 'voice_id' are printed out.
    #   # These keys in the voice dictionary contain values that provide information about the specific voice.
    #   puts "#{voice['name']}; #{voice['voice_id']}"
    # end
    puts data
