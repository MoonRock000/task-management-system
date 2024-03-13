# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
queues = [{ priority: 'Low' }, { priority: 'Medium' }, { priority: 'High' }]
users = [{ full_name: 'User 1' }]
tasks = [
  { title: 'Task 1' },
  { title: 'Task 2' },
  { title: 'Task 3' },
  { title: 'Task 4' },
  { title: 'Task 5' }
]
assigned_tasks = tasks.first(2)
prioritized_tasks = [tasks[0], tasks[2], tasks[3]]

created_tasks = tasks.map { |task_hash| Task.find_or_create_by!(task_hash) }

queues.each_with_index do |queue_hash, index|
  queue = TaskQueue.find_or_create_by!(queue_hash)
  created_tasks[index].update(task_queue: queue)
end

users.each do |user_hash|
  user = User.find_or_create_by!(user_hash)
  Task.where(title: assigned_tasks.pluck(:title)).update_all(user_id: user.id)
end
