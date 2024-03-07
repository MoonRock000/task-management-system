class TaskQueue < ApplicationRecord
  has_many :tasks

  validates :priority, presence: true
  validates :priority, uniqueness: true
end
