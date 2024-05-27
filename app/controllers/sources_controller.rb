class SourcesController < ApplicationController
  def index
    @user = current_user
    @sources = Source.all
    @output = Output.new
  end

  def reddit
    if params[:query].present?
      @reddit_script = RedditPost.new(params[:query]).top_post
      render json: {string: @reddit_script}
    end
  end

  def show
    @user = current_user
    @source = Source.find(params[:id])
    @output = Output.new
  end

  def create
    @owner = current_user
    @source = Source.new(source_params)
    if @source.save
      redirect_to source_path(@source)
      puts 'saved'
    else
      render 'pages/home', status: :unprocessable_entity
      puts 'not saved'
    end
  end

  def new
    @user = current_user
    @source = Source.new
  end

private

  def source_params
    params.require(:source).permit(:url)
  end
end
