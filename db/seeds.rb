# db/seeds.rb

# Clear existing data to avoid duplicates (optional, but recommended in development)
Source.delete_all
puts 'Deleted all sources'

videos = ['source-1', 'source-2', 'source-3']

# Create new Source instances and attach videos
videos.each_with_index do |video, index|
  source = Source.new(url: 'hello', location: 'world')
  source.video.attach(io: File.open("app/assets/images/#{video}.mp4"), filename: "#{video}.mp4", content_type: 'video/mp4')
  source.save!
  puts "Seeded Source ##{index + 1} with video #{video}"
end

puts "Created #{videos.size} sources with url 'hello', location 'world', and attached videos"
