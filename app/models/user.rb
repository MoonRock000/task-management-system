class User < ApplicationRecord
  has_many :tasks

  validates :full_name, presence: true
end
