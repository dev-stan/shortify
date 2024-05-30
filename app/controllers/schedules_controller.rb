class SchedulesController < ApplicationController
  def index

    start_date =  params.fetch(:start_date, Date.today).to_date
    @schedules = Schedule.where(publish_time: start_date.beginning_of_month.beginning_of_week..start_date.end_of_month.end_of_week)
  end
  def new
    @schedule = Schedule.new
    @user = current_user
  end
  def create
    @schedule = Schedule.new(schedule_params)
    @output = Output.find(params[:output_id])
    @schedule.output = @output.url
    if @schedule.save
      redirect_to output_schedules_path
      puts 'saved'

    else
      render 'pages/home', status: :unprocessable_entity
      puts 'not saved'
    end
  end
  def time
    "#{publish_time.strftime('%I:%M %p')}"
  end

  private

  def schedule_params
    params.require(:schedule).permit(:publish_time)
  end
end
