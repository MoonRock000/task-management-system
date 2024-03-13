class CreateTaskQueues < ActiveRecord::Migration[7.1]
  def change
    create_table :task_queues do |t|
      t.string :priority, default: '', null: false, index: { unique: true }

      t.timestamps
    end
  end
end
