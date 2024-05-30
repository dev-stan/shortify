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
    @client = OpenAI::Client.new
    params[:selected_posts].each do |script|
      @output = Output.new(source: Source.first) #@output = Output.new(output_params)
      @output.script = script
      # @output.script = GenerateVideo.new(script).final_video_link
      @output.user = current_user

      chaptgpt_response_title = client.chat(parameters: {
        model: "gpt-3.5-turbo",
        messages: [{ role: "user", content: "Give me a short, effective video title for the following script: #{@output.script}'."}]
      })
      @output.suggested_title = chaptgpt_response_title["choices"][0]["message"]["content"]

      chaptgpt_response_description = client.chat(parameters: {
        model: "gpt-3.5-turbo",
        messages: [{ role: "user", content: "Give me an effective video description (one paragraph) for the following script: #{@output.script}'."}]
       })
      @output.suggested_description = chaptgpt_response_description["choices"][0]["message"]["content"]

       chaptgpt_response_hashtags = client.chat(parameters: {
         model: "gpt-3.5-turbo",
        messages: [{ role: "user", content: "Give me a set of hashtags based on the content of the following script: #{@output.script}'."}]
      })
      @output.suggested_hashtags = chaptgpt_response_hashtags["choices"][0]["message"]["content"]

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
