class Gym < ApplicationRecord
  has_many :gym_schedules, dependent: :destroy

  validates :name, presence: true
end
