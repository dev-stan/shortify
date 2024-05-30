class BatchesController < ApplicationController

  def reddit
    @output = Output.new
    if params[:query].present?
      reddit_posts = RedditPost.new(params[:query]).top_posts
    end
    @reddit_card = render_to_string partial: "batches/reddit_card", locals: {posts: reddit_posts}, formats: [:html]
    p @reddit_card
    render json: {html: @reddit_card}
  end

  def show
    @user = current_user
    @sources = Source.all
    @output = Output.new
    @batch = Batch.find(params[:id])
  end

  def edit
    @batch = Batch.find(params[:id])
  end

  def update
    @batch = Batch.find(params[:id])
    if @batch.update(batch_params)
      @batch.outputs.each do |output|
        # Assuming GenerateVideo.new returns an object with a final_video_link method
        generated_video = GenerateVideo.new(output.source.video.url, output.script)
        output.url = generated_video.final_video_link
        output.save! # Ensure to save the changes
      end
      redirect_to batch_path(@batch)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def create
    @owner = current_user
    @batch = Batch.new
    @batch.source = Source.last
    if @batch.save
      params[:selected_posts].each do |script|
        @output = Output.new #@output = Output.new(output_params)
        @output.batch = @batch
        @output.script = script
        @output.source = Source.last
        # @output.script = GenerateVideo.new(script).final_video_link
        @output.user = current_user
        @output.save!
      end

      redirect_to batch_path(@batch)
    else
      render 'pages/home', status: :unprocessable_entity
      puts 'not saved'
    end
  end

  def new
    @user = current_user
    @batch = Batch.new
    @subs = ['Stories', 'todayilearned', 'aita', 'todayilearned', 'ExplainLikeImFive', 'Showerthoughts', 'Jokes', 'LifeProTips', 'nottheonion']
  end

private

  def batch_params
    params.require(:batch).permit(:font_family, :font_size, :font_style)
  end
end
