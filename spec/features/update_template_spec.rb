# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../rails_helper'
require_relative '../support/login_helper'

RSpec.configure do |c|
  c.include LoginHelper
end

feature 'Update template', js: true do
  given(:user) { FactoryBot.create(:user, :password_same_login, login: 'test-manager', language: 'en', admin: false) }
  given(:project) { FactoryBot.create(:project_with_enabled_modules) }
  given(:tracker) { FactoryBot.create(:tracker, :with_default_status) }
  given(:role) { FactoryBot.create(:role, :manager_role) }
  given(:status) { IssueStatus.create(name: 'open', is_closed: false) }
  given(:expected_note_description) { 'Note Template desctiption' }
  given!(:template) {
    NoteTemplate.create(project_id: project.id, tracker_id: tracker.id,
      name: 'Note Template name', description: expected_note_description, enabled: true)
  }

  background(:all) do
    Redmine::Plugin.register(:redmine_issue_templates) do
      settings partial: 'settings/redmine_issue_templates',
               default: { 'apply_global_template_to_all_projects' => 'false', 'apply_template_when_edit_issue' => 'true' }
    end
  end

  background do
    project.trackers << tracker

    priority = IssuePriority.create(
      name: 'Low',
      position: 1, is_default: false, type: 'IssuePriority', active: true, project_id: nil, parent_id: nil,
      position_name: 'lowest'
    )

    member = Member.new(project: project, user_id: user.id)
    member.member_roles << MemberRole.new(role: role)
    member.save

    Issue.create(project_id: project.id, tracker_id: tracker.id,
                 author_id: user.id,
                 priority: priority,
                 subject: 'test_create',
                 status_id: status.id,
                 description: 'IssueTest#test_create')
  end

  context 'Have show_issue_template permission' do

    background do
      assign_template_priv(role, add_permission: :show_issue_templates)
    end

    scenario 'Cannot edit the template, only view it' do
      visit_log_user(user)
      visit "/projects/#{project.identifier}/note_templates/#{template.id}"
      sleep(0.2)
      expect(page).to have_no_selector('div#edit-note_template')
      expect(page).to have_selector('div#view-note_template')
    end
  end

  context 'Have edit_issue_template permission' do

    background do
      assign_template_priv(role, add_permission: :edit_issue_templates)
      assign_template_priv(role, add_permission: :show_issue_templates)
    end

    scenario 'Can edit the template, and view it' do
      visit_log_user(user)
      visit "/projects/#{project.identifier}/note_templates/#{template.id}"
      sleep(0.2)
      expect(page).to have_selector('div#edit-note_template')
      expect(page).to have_no_selector('div#view-note_template')
    end
  end

  private

  def visit_log_user(user)
    user.update_attribute(:admin, false)
    log_user(user.login, user.login)
  end
end
