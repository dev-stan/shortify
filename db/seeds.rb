# db/seeds.rb

Source.delete_all
Output.destroy_all
Source.destroy_all
puts 'Deleted all sources'

videos = [
  'https://res.cloudinary.com/dcug1pvpk/video/upload/v1716529220/lazyreel-seeds/source-1.mp4',
  'https://res.cloudinary.com/dcug1pvpk/video/upload/v1716529211/lazyreel-seeds/source-2.mp4',
  'https://res.cloudinary.com/dcug1pvpk/video/upload/v1716529209/lazyreel-seeds/source-3.mp4',

]

# Create new Source instances and attach videos
videos.each_with_index do |video, index|
  source = Source.new(url: 'url not needed - stan', location: 'location not needed - stan')
  # source.video.attach(io: File.open("app/assets/images/#{video}.mp4"), filename: "#{video}.mp4", content_type: 'video/mp4')
  file = URI.open(video)
  source.video.attach(io: file, filename: "#{video}.mp4", content_type: 'video/mp4')
  source.url = source.video.url
  source.save!
  puts "(sources) Seeded Source ##{index + 1} with video #{video}, url: #{source.url}"
end

puts "Created #{videos.size} and attached videos"
