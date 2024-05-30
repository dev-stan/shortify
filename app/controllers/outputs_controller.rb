class OutputsController < ApplicationController
def index
  @user = current_user
  @outputs = Output.all # Fix this later!! should be current user and not all outputs
  @sources = Source.all
end

  def new
    @output = Output.new
    @user = current_user
  end

  def create
    params[:selected_posts].each do |script|
      @output = Output.new(source: Source.first) #@output = Output.new(output_params)
      @output.script = script
      # @output.script = GenerateVideo.new(script).final_video_link
      @output.user = current_user
      if @output.save
        puts 'saved'
      else
        render 'pages/sources', status: :unprocessable_entity
        puts 'not saved'
        p @output.valid?
        p @output.errors.messages
        flash.alert = "Output failed."
      end
    end
    redirect_to sources_video_path
  end

  def show
    @output = Output.find(params[:id])
    @schedule = Schedule.new
    start_date =  params.fetch(:start_date, Date.today).to_date
    @schedules = Schedule.where(publish_time: start_date.beginning_of_month.beginning_of_week..start_date.end_of_month.end_of_week)
  end

  def download
    @output = Output.find(params[:id])
    @video = @output.url
    send_file(
      @video,
      filename: "video.mp4",
      type: "video/mp4"
    )
  end

  def output_params
    # params.require(:output).permit(:script, :font_family, :font_style, :voice)
    params.require(:output).permit(:source_id, :font_family, :font_style, :font_size, :script, :voice)
  end
end
