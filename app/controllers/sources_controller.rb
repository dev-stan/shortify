class SourcesController < ApplicationController
  def index
    @user = current_user
    @sources = Source.all
    @output = Output.new
  end

  def reddit
    if params[:query].present?
      reddit_post = RedditPost.new(params[:query]).top_post
      @reddit_card = render_to_string partial: "sources/reddit_card", locals: {post: reddit_post}, formats: [:html]
      render json: {html: @reddit_card}
    end
  end

  def video
    @user = current_user
    @sources = Source.all
    @output = Output.new
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
