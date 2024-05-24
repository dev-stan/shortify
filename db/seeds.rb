# db/seeds.rb

Source.delete_all
Output.destroy_all
Source.destroy_all
puts 'Deleted all sources'

videos = ['source-1', 'source-2', 'source-3']

# Create new Source instances and attach videos
videos.each_with_index do |video, index|
  source = Source.new(url: 'hello', location: 'world')
  source.video.attach(io: File.open("app/assets/images/#{video}.mp4"), filename: "#{video}.mp4", content_type: 'video/mp4')
  source.url = source.video.url
  source.save!
  puts "Seeded Source ##{index + 1} with video #{video}, url: #{source.url}"
end

puts "Created #{videos.size} and attached videos"



video.attach(io: 'https://res.cloudinary.com/dcug1pvpk/video/upload/v1716529190/lazyreel-seeds/story-video-1.mp4', filename: "#{video}.mp4", content_type: 'video/mp4')

