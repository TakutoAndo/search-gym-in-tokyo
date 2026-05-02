class Admin::GymsController < ApplicationController
  before_action :set_gym, only: [:show, :edit, :update, :destroy]

  def index
    @gyms = Gym.order(:ward, :name)
  end

  def show
    @schedules = @gym.gym_schedules.order(:day_of_week, :start_time)
  end

  def new
    @gym = Gym.new
  end

  def create
    @gym = Gym.new(gym_params)
    if @gym.save
      redirect_to admin_gym_path(@gym), notice: '施設を登録しました'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @gym.update(gym_params)
      redirect_to admin_gym_path(@gym), notice: '施設情報を更新しました'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @gym.destroy
    redirect_to admin_gyms_path, notice: '施設を削除しました'
  end

  private

  def set_gym
    @gym = Gym.find(params[:id])
  end

  def gym_params
    params.require(:gym).permit(
      :name, :address, :ward, :postal_code, :nearest_station,
      :phone, :website, :reservation_url, :notes
    )
  end
end
