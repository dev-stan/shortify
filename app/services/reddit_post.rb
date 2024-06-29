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

  def top_posts
    token = get_token
    limit = 200
    after = nil
    suitable_posts = []

    n = 0
    while suitable_posts.size < 9
      n += 1
      break if n > 15

      top_posts, after = fetch_top_posts(token, limit: limit, after: after)

      top_posts.each do |post|
        content = post['selftext']
        title = post['title']
        id = post['id']

        next if content.nil? || content.empty?

        if content.split.size <= 250 && suitable_posts.none? { |p| p[:id] == id }
          suitable_posts << { content: content, title: title, id: id }
          break if suitable_posts.size == 9
        end
      end
    end

    return suitable_posts.size == 9 ? suitable_posts : [{ content: 'no', title: 'no', id: 0 }]
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

  def fetch_top_posts(token, limit: 1, after: nil)
    top_posts_url = "https://oauth.reddit.com/r/#{@subreddit}/top?limit=#{limit}&t=year"
    top_posts_url += "&after=#{after}" if after
    uri = URI(top_posts_url)
    req = Net::HTTP::Get.new(uri)
    req['Authorization'] = "Bearer #{token}"
    req['User-Agent'] = USER_AGENT

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end

    data = JSON.parse(res.body)['data']
    [data['children'].map { |post| post['data'] }, data['after']]
  end
end
