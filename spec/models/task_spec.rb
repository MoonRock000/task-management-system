require 'rails_helper'

RSpec.describe Task, type: :model do
  it { should belong_to(:user).optional(true) }
  it { should belong_to(:task_queue).optional(true) }
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:status) }
  it { should validate_numericality_of(:progress_percentage).is_greater_than_or_equal_to(0) }
  it { should define_enum_for(:status) }
end
