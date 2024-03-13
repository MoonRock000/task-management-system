class Task < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :task_queue, optional: true

  validates :title, presence: true
  validates :status, presence: true
  validates :progress_percentage, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  enum :status, { todo: 0, in_progress: 1, completed: 2 }
end
