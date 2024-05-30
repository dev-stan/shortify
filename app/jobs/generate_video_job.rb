class GenerateVideoJob < ApplicationJob
  queue_as :default

  def perform(source_url, script)
    GenerateVideo.new(source_url, script).final_video_link
  end
end
