require 'youtube-captions'
require 'json'

video = YoutubeCaptions::Video.new(id: "X9G7Md8QI4k")
video.captions

p video.captions
