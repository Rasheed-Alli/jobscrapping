class CreateJobs < ActiveRecord::Migration[5.2]
  def change
    create_table :jobs do |t|
      t.string :location
      t.string :team
      t.string :job_title
      t.string :url
      t.text :job_description

      t.timestamps
    end
  end
end
