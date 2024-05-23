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
    @output.user = current_user
        if @output.save
      redirect_to sources_path
      puts 'saved'
    else
      render 'pages/home', status: :unprocessable_entity
      puts 'not saved'
    end
  end

  def output_params
    params.require(:output).permit(:source_id, :font_family, :font_style, :font_size, :script, :voice)
  end
end
