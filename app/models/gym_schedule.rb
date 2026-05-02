class GymSchedule < ApplicationRecord
  belongs_to :gym

  DAY_NAMES = %w[日 月 火 水 木 金 土].freeze
end
