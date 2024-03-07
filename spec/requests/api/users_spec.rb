require 'rails_helper'

RSpec.describe 'Api::Users', type: :request do
  describe 'GET /api/users' do
    let(:user) { create(:user) }
    let!(:unassigned_task) do
      tasks = create_list(:task, 3, user:)
      tasks.last.update(user: nil)
      tasks.last
    end

    before { get tasks_api_user_path(user) }

    it 'responds with 200' do
      expect(response).to have_http_status(200)
    end

    it 'returns the assigned tasks' do
      expect(json['tasks']).not_to be_nil
      expect(json['tasks'].count).to eq(2)
      expect(json['tasks'].pluck('id')).not_to include(unassigned_task.id)
    end
  end
end
