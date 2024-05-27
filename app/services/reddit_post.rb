# /mnt/data/get_top_askreddit_post.rb

require 'net/http'
require 'uri'
require 'json'

class RedditPost

  def initialize(subreddit)
    @subreddit = 'stories'
  end


  CLIENT_ID = ENV['REDDIT_CLIENT_ID']
  SECRET = ENV['REDDIT_SECRET']
  USER_AGENT = 'RubyScript/1.0'

  AUTH_URL = 'https://www.reddit.com/api/v1/access_token'
  TOP_POST_URL = "https://oauth.reddit.com/r/stories/top?limit=1&t=day"


  def top_post
    token = get_token
    top_post = fetch_top_post(token)

    content = top_post['selftext']
    title = top_post['title']
    url = top_post['url']
    upvotes = top_post['score']

    return content
  end

  private

  # Get the OAuth token using client credentials
  def get_token
    uri = URI(AUTH_URL)
    req = Net::HTTP::Post.new(uri)
    req.basic_auth(CLIENT_ID, SECRET)
    req.set_form_data('grant_type' => 'client_credentials')
    req['User-Agent'] = USER_AGENT

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end

    JSON.parse(res.body)['access_token']
  end

  # Fetch the top post
  def fetch_top_post(token)
    uri = URI(TOP_POST_URL)
    req = Net::HTTP::Get.new(uri)
    req['Authorization'] = "Bearer #{token}"
    req['User-Agent'] = USER_AGENT

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end

    JSON.parse(res.body)['data']['children'].first['data']
    # JSON.parse(res.body)['data']['children'].first['data']
  end
end
