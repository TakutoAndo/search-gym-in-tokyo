class GymsController < ApplicationController
  def index
    @gyms = Gym.all

    if params[:ward].present?
      @gyms = @gyms.where(ward: params[:ward])
    end

    if params[:has_website].present?
      @gyms = @gyms.where.not(website: [nil, ""])
    end

    if params[:keyword].present?
      keyword = "%#{params[:keyword]}%"
      @gyms = @gyms.where(
        'name LIKE :q OR address LIKE :q OR nearest_station LIKE :q',
        q: keyword
      )
    end

    @gyms = @gyms.order(:ward, :name)
    @wards = Gym.distinct.order(:ward).pluck(:ward).compact
  end

  def show
    @gym = Gym.find(params[:id])
    @schedules = @gym.gym_schedules.order(:day_of_week, :start_time)
  end
end
