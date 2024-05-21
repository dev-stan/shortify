class OutputsController < ApplicationController

  def new
    @output = Output.new
  end

  def create
    @output = Output.new
    @owner = current_user
    @source = Source.find(params[:id])
    if @output.save
      redirect_to source_path(@source)
      puts 'saved'
    else
      render 'pages/home', status: :unprocessable_entity
      puts 'not saved'
    end
  end
end
