class ChangeGlobalNoteTemplateProjectsTableName < ActiveRecord::Migration[6.1]
  def up
    rename_table :global_note_template_projects, :global_note_templates_projects
  end

  def down
    rename_table :global_note_templates_projects, :global_note_template_projects
  end
end
