require 'net/http'
require 'uri'
require 'json'
require 'dotenv/load'

class RedditPost

  def initialize(subreddit)
    @subreddit = subreddit.to_s
  end

  CLIENT_ID = ENV['REDDIT_CLIENT_ID']
  SECRET = ENV['REDDIT_SECRET']
  USER_AGENT = 'RubyScript/1.0'

  AUTH_URL = 'https://www.reddit.com/api/v1/access_token'

  def top_post
    token = get_token
    top_posts = fetch_top_posts(token, limit: 10)

    random_post = top_posts.sample
    content = random_post['selftext']
    title = random_post['title']
    url = random_post['url']
    upvotes = random_post['score']

    if content.nil? || content.empty?
      return title
    end

    return content
  end

  private

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

  def fetch_top_posts(token, limit: 1)
    top_posts_url = "https://oauth.reddit.com/r/#{@subreddit}/top?limit=#{limit}&t=month"
    uri = URI(top_posts_url)
    req = Net::HTTP::Get.new(uri)
    req['Authorization'] = "Bearer #{token}"
    req['User-Agent'] = USER_AGENT

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end

    JSON.parse(res.body)['data']['children'].map { |post| post['data'] }
  end
end
