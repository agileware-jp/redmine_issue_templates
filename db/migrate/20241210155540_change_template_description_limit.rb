class ChangeTemplateDescriptionSizeLimit < ActiveRecord::Migration[5.2]
  def up
    if Redmine::Database.mysql?
      max_size = 16.megabytes
      change_column :issue_templates, :description, :text, :limit => max_size
      change_column :global_issue_templates, :description, :text, :limit => max_size
    end
  end

  def down
    # no-op
  end
end
