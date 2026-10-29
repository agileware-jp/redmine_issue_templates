# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../rails_helper'
require_relative '../support/login_helper'

RSpec.configure do |c|
  c.include LoginHelper
end

feature 'Create issue', js: true do
  given(:user) { FactoryBot.create(:user, login: 'test-manager', password: 'password', language: 'en', admin: false) }
  given(:project) { FactoryBot.create(:project_with_enabled_modules) }
  given(:tracker) { FactoryBot.create(:tracker, :with_default_status) }
  given(:role) { FactoryBot.create(:role, :manager_role) }
  given(:status) { IssueStatus.create(name: 'open', is_closed: false) }
  given(:issue_note) { page.find('textarea#issue_notes') }

  background(:all) do
    Redmine::Plugin.register(:redmine_issue_templates) do
      settings partial: 'settings/redmine_issue_templates',
               default: { 'apply_global_template_to_all_projects' => 'false', 'apply_template_when_edit_issue' => 'true' }
    end
  end

  background do
    project.trackers << tracker
    assign_template_priv(role, add_permission: :show_issue_templates)
    member = Member.new(project: project, user_id: user.id)
    member.member_roles << MemberRole.new(role: role)
    member.save
  end

  describe 'apply default issue template' do
    background do
      FactoryBot.create(
        :issue_template,
        project_id: project.id,
        tracker_id: tracker.id,
        issue_title: 'default issue title',
        description: 'default issue description',
        is_default: is_default,
      )
    end

    context 'is_default: true' do
      let(:is_default) { true }
      scenario 'Select tracker and apply default template' do
        log_user(user.login, 'password')
        expect(page).to have_current_path(my_page_path, wait: 5)

        visit project_issues_new_path(project)
        expect(page).to have_current_path(project_issues_new_path(project), wait: 5)
        
        select tracker.name, from: 'issue[tracker_id]'
        expect(find('#issue_subject').value).to eq('default issue title')
        expect(find('#issue_description').value).to eq('default issue description')
      end
    end

    context 'is_default: false' do
      let(:is_default) { false }
      scenario 'Select tracker and apply default template' do
        log_user(user.login, user.password)
        expect(page).to have_current_path(my_page_path, wait: 5)

        visit new_project_issue_path(project)
        expect(page).to have_current_path(new_project_issue_path(project), wait: 5)

        select tracker.name, from: 'issue[tracker_id]'
        expect(find('#issue_subject').value).to eq('')
        expect(find('#issue_description').value).to eq('')
      end
    end
  end

  describe 're-render the new issue form after a validation error' do
    given(:edited_subject) { 'default issue title (edited)' }
    given(:edited_description) { "default issue description\n\nedited by the operator" }

    background do
      FactoryBot.create(
        :issue_template,
        project_id: project.id,
        tracker_id: tracker.id,
        issue_title: 'default issue title',
        description: 'default issue description',
        is_default: true
      )
      # Make the issue invalid on create so that the new issue form is re-rendered with an error.
      custom_field = IssueCustomField.create!(name: 'Required field', field_format: 'string',
                                              is_required: true, is_for_all: true)
      custom_field.trackers << tracker
    end

    scenario 'Default template is not applied again to the edited content' do
      # GitHub issue #76. This happens regardless of apply_template_when_edit_issue.
      Setting.send 'plugin_redmine_issue_templates=', 'apply_template_when_edit_issue' => 'false'

      log_user(user.login, user.password)
      expect(page).to have_current_path(my_page_path, wait: 5)

      visit new_project_issue_path(project)
      expect(page).to have_current_path(new_project_issue_path(project), wait: 5)
      expect(page).to have_field('issue_subject', with: 'default issue title', wait: 5)
      expect(page).to have_field('issue_description', with: 'default issue description', wait: 5)

      fill_in 'issue_subject', with: edited_subject
      fill_in 'issue_description', with: edited_description

      2.times do
        page.find('#issue-form input[name=commit]').click
        expect(page).to have_selector('#errorExplanation')
        expect(page).to have_selector('div#template_area', visible: true)
        sleep(1)
        expect(find('#issue_subject').value).to eq(edited_subject)
        expect(find('#issue_description', visible: :all).value).to eq(edited_description)
      end
    end
  end
end
