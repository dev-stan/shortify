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
    @output.url = GenerateVideo.new('https://drive.google.com/uc?export=download&id=181aL20cO8Jvvpz4MtWvvyEoysQjyZUdh', @output.script).final_video_link
    @output.source = 'https://drive.google.com/uc?export=download&id=181aL20cO8Jvvpz4MtWvvyEoysQjyZUdh'
    @output.user = current_user
        if @output.save
      redirect_to sources_path
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

  def output_params
    params.require(:output).permit(:script, :font_family, :font_style, :voice)
  end
end
