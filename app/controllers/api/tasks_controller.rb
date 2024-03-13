class Api::TasksController < ApplicationController
  before_action :set_task, only: %i[update destroy assign progress]
  before_action :set_user, only: %i[assign]

  def index
    render json: { tasks: Task.all }
  end

  def create
    task = Task.new(task_params.permit(:title, :description))

    if task.save
      render json: { task: }
    else
      render json: { errors: task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @task.update(task_params)
      render json: { task: @task }
    else
      render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    render json: { task: @task.destroy }
  end

  def assign
    if @task.update(user: @user)
      render json: { message: 'Task assigned successfully' }
    else
      render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def progress
    if @task.update(progress_percentage: request_params[:progress_percentage])
      render json: { message: 'Task progress updated successfully' }
    else
      render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def overdue
    current_time = DateTime.current
    tasks = Task.where('due_date >= ?', current_time)
    render json: { tasks: }
  end

  def status
    tasks = Task.where(status: request_params[:status])
    render json: { tasks: }
  end

  def completed
    start_date = request_params[:start_date]&.to_datetime
    end_date = request_params[:end_date]&.to_datetime
    tasks = Task.completed
    tasks = tasks.where('completed_at >= ?', start_date) if start_date.present?
    tasks = tasks.where('completed_at <= ?', end_date) if end_date.present?
    render json: { tasks: }
  end

  def statistics
    completed_count = Task.completed.count
    total_count = Task.count
    render json: {
      statistics: {
        total_count:, completed_count:, completed_percentage: completed_count.to_f / total_count
      }
    }
  end

  private

  def set_task
    @task = Task.find(params[:id])
  end

  def set_user
    @user = User.find(params[:user_id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :due_date, :status)
  end

  def request_params
    params.permit(:progress_percentage, :status, :start_date, :end_date)
  end
end
