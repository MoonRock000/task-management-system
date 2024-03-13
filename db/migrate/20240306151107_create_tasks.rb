class CreateTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :tasks do |t|
      t.string :title, default: '', null: false
      t.text :description
      t.datetime :due_date
      t.decimal :progress_percentage
      t.datetime :completed_at
      t.integer :status, default: 0, null: false
      t.references :user, null: true, foreign_key: true
      t.references :task_queue, null: true, foreign_key: true

      t.timestamps
    end
  end
end
