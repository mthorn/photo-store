class AddExternalJobId < ActiveRecord::Migration
  def change
    add_column :uploads, :external_job_id, :string
  end
end
