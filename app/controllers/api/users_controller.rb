class Api::UsersController < ApplicationController
  before_action :set_user, only: %i[tasks]

  def tasks
    user_tasks = @user.tasks
    render json: { tasks: user_tasks }
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
