require 'rails_helper'

RSpec.describe TaskQueue, type: :model do
  it { should have_many(:tasks) }
  it { should validate_presence_of(:priority) }
  it { should validate_uniqueness_of(:priority) }
end
