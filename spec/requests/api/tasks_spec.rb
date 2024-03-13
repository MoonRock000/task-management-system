require 'rails_helper'

RSpec.describe 'Api::Tasks', type: :request do
  describe 'GET /api/tasks' do
    let!(:tasks) { create_list(:task, 3) }

    context 'when valid' do
      before { get api_tasks_path }

      it 'responds with 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the tasks' do
        expect(json['tasks']).not_to be_nil
        expect(json['tasks'].count).to eq(3)
        expect(json['tasks'].pluck('id')).to include(tasks.first.id)
      end
    end
  end

  describe 'POST /api/tasks' do
    context 'when valid' do
      let(:task_params) do
        { title: 'Test Task' }
      end

      before do |example|
        post api_tasks_path, params: { task: task_params } unless example.metadata[:exempt]
      end

      it 'responds with 200' do
        expect(response).to have_http_status(200)
      end

      it 'creates the task', exempt: true do
        expect { post api_tasks_path, params: { task: task_params } }
          .to change { Task.count }.from(0).to(1)
      end

      it 'returns created task' do
        expect(json['task']).not_to be_nil
        expect(json['task']['title']).to eq(task_params[:title])
      end
    end

    context 'when invalid' do
      context 'due to empty title' do
        let(:task_params) do
          { title: '' }
        end

        before do |example|
          post api_tasks_path, params: { task: task_params } unless example.metadata[:exempt]
        end

        it 'responds with 422' do
          expect(response).to have_http_status(422)
        end

        it 'does not create the task', exempt: true do
          expect { post api_tasks_path, params: { task: task_params } }
            .not_to change { Task.count }.from(0)
        end

        it 'returns errors' do
          expect(json['errors']).not_to be_nil
          expect(json['errors'].first).to eq("Title can't be blank")
        end
      end
    end
  end

  describe 'PUT /api/tasks/:id' do
    let!(:task) { create(:task, title: 'Test Task') }

    context 'when valid' do
      let(:task_params) do
        { title: 'Test Task Updated' }
      end

      before do |example|
        put api_task_path(task), params: { task: task_params } unless example.metadata[:exempt]
      end

      it 'responds with 200' do
        expect(response).to have_http_status(200)
      end

      it 'updates the task', exempt: true do
        expect { put api_task_path(task), params: { task: task_params } }
          .to change { task.reload.title }.from('Test Task').to(task_params[:title])
      end

      it 'returns updated task' do
        expect(json['task']).not_to be_nil
        expect(json['task']['id']).to eq(task.id)
      end
    end

    context 'when invalid' do
      context 'due to empty title' do
        let(:task_params) do
          { title: '' }
        end

        before do |example|
          put api_task_path(task), params: { task: task_params } unless example.metadata[:exempt]
        end

        it 'responds with 422' do
          expect(response).to have_http_status(422)
        end

        it 'does not update the task', exempt: true do
          expect { put api_task_path(task), params: { task: task_params } }
            .not_to change { task.reload.title }.from('Test Task')
        end

        it 'returns errors' do
          expect(json['errors']).not_to be_nil
          expect(json['errors'].first).to eq("Title can't be blank")
        end
      end

      context 'due to empty status' do
        let(:task_params) do
          { title: 'Test Task', status: '' }
        end

        before do |example|
          put api_task_path(task), params: { task: task_params } unless example.metadata[:exempt]
        end

        it 'responds with 422' do
          expect(response).to have_http_status(422)
        end

        it 'does not update the task', exempt: true do
          expect { put api_task_path(task), params: { task: task_params } }
            .not_to change { task.reload.status }.from('todo')
        end

        it 'returns errors' do
          expect(json['errors']).not_to be_nil
          expect(json['errors'].first).to eq("Status can't be blank")
        end
      end
    end
  end

  describe 'DELETE /api/tasks/:id' do
    context 'when valid' do
      let!(:task) { create(:task, title: 'Test Task') }

      before do |example|
        delete api_task_path(task) unless example.metadata[:exempt]
      end

      it 'responds with 200' do
        expect(response).to have_http_status(200)
      end

      it 'destroys the task', exempt: true do
        expect { delete api_task_path(task) }
          .to change { Task.count }.from(1).to(0)
      end

      it 'returns destroyed task' do
        expect(json['task']).not_to be_nil
        expect(json['task']['id']).to eq(task.id)
      end
    end
  end

  describe 'POST /api/tasks/:id/assign' do
    context 'when valid' do
      let(:user) { create(:user) }
      let!(:task) { create(:task, title: 'Test Task') }
      let(:assign_params) do
        { user_id: user.id }
      end

      before do |example|
        post assign_api_task_path(task), params: assign_params unless example.metadata[:exempt]
      end

      it 'responds with 200' do
        expect(response).to have_http_status(200)
      end

      it 'assigns the task to user', exempt: true do
        expect { post assign_api_task_path(task), params: assign_params }
          .to change { task.reload.user_id }.from(nil).to(assign_params[:user_id])
      end

      it 'returns success message' do
        expect(json['message']).to eq('Task assigned successfully')
      end
    end

    context 'when invalid' do
      let!(:task) { create(:task, title: 'Test Task') }

      context 'due to invalid user_id' do
        let(:assign_params) do
          { user_id: 'invalid_id' }
        end

        before do |example|
          post assign_api_task_path(task), params: assign_params unless example.metadata[:exempt]
        end

        it 'responds with 404' do
          expect(response).to have_http_status(404)
        end

        it 'does not assign the task to user', exempt: true do
          expect { post assign_api_task_path(task), params: assign_params }
            .not_to change { task.reload.user_id }.from(nil)
        end

        it 'returns errors' do
          expect(json['errors']).not_to be_nil
          expect(json['errors'].first).to eq('Unable to find the resource')
        end
      end
    end
  end

  describe 'PUT /api/tasks/:id/progress' do
    context 'when valid' do
      let!(:task) { create(:task, title: 'Test Task') }
      let(:progress_params) do
        { progress_percentage: 30.0 }
      end

      before do |example|
        put progress_api_task_path(task), params: progress_params unless example.metadata[:exempt]
      end

      it 'responds with 200' do
        expect(response).to have_http_status(200)
      end

      it 'updates progress percentage', exempt: true do
        expect { put progress_api_task_path(task), params: progress_params }
          .to change { task.reload.progress_percentage }.from(nil).to(progress_params[:progress_percentage])
      end

      it 'returns success message' do
        expect(json['message']).to eq('Task progress updated successfully')
      end
    end

    context 'when invalid' do
      context 'due to non-numeric progress_percentage' do
        let!(:task) { create(:task, title: 'Test Task') }
        let(:progress_params) do
          { progress_percentage: 'invalid' }
        end

        before do |example|
          put progress_api_task_path(task), params: progress_params unless example.metadata[:exempt]
        end

        it 'responds with 422' do
          expect(response).to have_http_status(422)
        end

        it 'does not update progress percentage', exempt: true do
          expect { put progress_api_task_path(task), params: progress_params }
            .not_to change { task.reload.progress_percentage }.from(nil)
        end

        it 'returns errors' do
          expect(json['errors']).not_to be_nil
          expect(json['errors'].first).to eq('Progress percentage is not a number')
        end
      end

      context 'due to negative progress_percentage' do
        let!(:task) { create(:task, title: 'Test Task') }
        let(:progress_params) do
          { progress_percentage: -1 }
        end

        before do |example|
          put progress_api_task_path(task), params: progress_params unless example.metadata[:exempt]
        end

        it 'responds with 422' do
          expect(response).to have_http_status(422)
        end

        it 'does not update progress percentage', exempt: true do
          expect { put progress_api_task_path(task), params: progress_params }
            .not_to change { task.reload.progress_percentage }.from(nil)
        end

        it 'returns errors' do
          expect(json['errors']).not_to be_nil
          expect(json['errors'].first).to eq('Progress percentage must be greater than or equal to 0')
        end
      end
    end
  end

  describe 'GET /api/tasks/overdue' do
    context 'when valid' do
      let(:mock_current_time) { Time.utc(2024, 1, 2) }
      let!(:non_overdue_task) do
        tasks = create_list(:task, 3, due_date: mock_current_time.next_day)
        tasks.last.update(due_date: mock_current_time.prev_day)
        tasks.last
      end

      before do
        travel_to mock_current_time
        get overdue_api_tasks_path
      end

      after { travel_back }

      it 'responds with 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the overdue tasks' do
        expect(json['tasks']).not_to be_nil
        expect(json['tasks'].count).to eq(2)
        expect(json['tasks'].pluck('id')).not_to include(non_overdue_task.id)
      end
    end
  end

  describe 'GET /api/tasks/status/:status' do
    context 'when valid' do
      let(:status) { 'in_progress' }
      let!(:completed_task) do
        tasks = create_list(:task, 3, status:)
        tasks.last.update(status: 'completed')
        tasks.last
      end

      before { get status_api_tasks_path(status) }

      it 'responds with 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the tasks in progress' do
        expect(json['tasks']).not_to be_nil
        expect(json['tasks'].count).to eq(2)
        expect(json['tasks'].pluck('id')).not_to include(completed_task.id)
      end
    end
  end

  describe 'GET /api/tasks/completed' do
    context 'when valid' do
      let(:completed_at_time) { Time.utc(2024, 1, 1).change(hour: 12) }
      let(:range_params) do
        { start_date: completed_at_time.beginning_of_day, end_date: completed_at_time.end_of_day }
      end
      let!(:out_of_range_task) do
        tasks = create_list(:task, 3, status: 'completed', completed_at: completed_at_time)
        tasks.last.update(completed_at: completed_at_time.next_day)
        tasks.last
      end

      before { get completed_api_tasks_path, params: range_params }

      it 'responds with 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the completed tasks in range' do
        expect(json['tasks']).not_to be_nil
        expect(json['tasks'].count).to eq(2)
        expect(json['tasks'].pluck('id')).not_to include(out_of_range_task.id)
        expect(json['tasks'].pluck('status').all?('completed')).to be_truthy
      end
    end

    context 'when invalid' do
      context 'due to invalid filters' do
        let(:range_params) do
          { start_date: 'invalid', end_date: 'invalid' }
        end

        before { get completed_api_tasks_path, params: range_params }

        it 'responds with 500' do
          expect(response).to have_http_status(500)
        end

        it 'returns errors' do
          expect(json['errors']).not_to be_nil
        end
      end
    end
  end

  describe 'GET /api/tasks/statistics' do
    context 'when valid' do
      before do
        tasks = create_list(:task, 4, status: :completed)
        tasks.last.update(status: :in_progress)
        get statistics_api_tasks_path
      end

      it 'responds with 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the correct tasks statistics' do
        expect(json['statistics']).not_to be_nil
        expect(json['statistics']['total_count']).to eq(4)
        expect(json['statistics']['completed_count']).to eq(3)
        expect(json['statistics']['completed_percentage']).to eq(0.75)
      end
    end
  end
end
