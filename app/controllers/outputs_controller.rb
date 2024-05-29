class OutputsController < ApplicationController
def index
  @user = current_user
  @outputs = @user.outputs
  @sources = Source.all
end

  def new
    @output = Output.new
    @user = current_user
  end

  def create
    @output = Output.new(output_params)
    @output.url = GenerateVideo.new(@output.source.url, @output.script).final_video_link
    @output.user = current_user
        if @output.save
      redirect_to output_path(@output)
      puts 'saved'
      flash.notice = "Output created."
    else
      render 'pages/home', status: :unprocessable_entity
      puts 'not saved'
      p @output.valid?
      p @output.errors.messages
      flash.alert = "Output failed."
    end
  end

  def show
    @output = Output.find(params[:id])
    @schedule = Schedule.new
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
