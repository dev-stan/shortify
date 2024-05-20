module ApplicationHelper
  # this method will embed the code from the partial
  def youtube_video(url)
    render :partial => 'shared/videos', :locals => { :url => url }
  end
end
