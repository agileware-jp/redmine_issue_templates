# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../rails_helper'
require_relative '../support/login_helper'

RSpec.configure do |c|
  c.include LoginHelper
end

feature 'Create issue', js: true do
  given(:user) { FactoryBot.create(:user, :password_same_login, login: 'test-manager', language: 'en', admin: false) }
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
        log_user(user.login, user.login)
        visit "/projects/#{project.identifier}/issues/new"
        select tracker.name, from: 'issue[tracker_id]'
        expect(find('#issue_subject').value).to eq('default issue title')
        expect(find('#issue_description').value).to eq('default issue description')
      end
    end

    context 'is_default: false' do
      let(:is_default) { false }
      scenario 'Select tracker and apply default template' do
        log_user(user.login, user.login)
        visit "/projects/#{project.identifier}/issues/new"
        select tracker.name, from: 'issue[tracker_id]'
        expect(find('#issue_subject').value).to eq('')
        expect(find('#issue_description').value).to eq('')
      end
    end
  end
end
