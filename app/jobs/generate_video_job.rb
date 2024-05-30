class GenerateVideoJob < ApplicationJob
  queue_as :default

  def perform(source_url, script, output)
    new_url = GenerateVideo.new(source_url, script).final_video_link
    output.url = new_url
    output.save!
  end
end
