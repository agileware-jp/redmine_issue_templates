# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../rails_helper'
require_relative '../support/login_helper'

RSpec.configure do |c|
  c.include LoginHelper
end

feature 'Update issue', js: true do
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
    FactoryBot.create_list(:issue_template, 2, project_id: project.id, tracker_id: tracker.id)

    project.trackers << tracker
    assign_template_priv(role, add_permission: :show_issue_templates)
    member = Member.new(project: project, user_id: user.id)
    member.member_roles << MemberRole.new(role: role)
    member.save

    priority = IssuePriority.create(
      name: 'Low',
      position: 1, is_default: false, type: 'IssuePriority', active: true, project_id: nil, parent_id: nil,
      position_name: 'lowest'
    )

    Issue.create(project_id: project.id, tracker_id: tracker.id,
                 author_id: user.id,
                 priority: priority,
                 subject: 'test_create',
                 status_id: status.id,
                 description: 'IssueTest#test_create')
  end

  scenario 'Click edit link with apply_template_when_edit_issue flag', js: true do
    Setting.send 'plugin_redmine_issue_templates=', 'apply_template_when_edit_issue' => 'true'
    visit_update_issue(user)
    issue = Issue.last
    visit "/issues/#{issue.id}"
    page.find('#content > div:nth-child(1) > a.icon.icon-edit').click
    sleep(0.2)
    expect(page).to have_selector('div#template_area select#issue_template')
  end

  scenario 'Click edit link without apply_template_when_edit_issue flag', js: true do
    Setting.send 'plugin_redmine_issue_templates=', 'apply_template_when_edit_issue' => 'false'
    visit_update_issue(user)
    issue = Issue.last
    visit "/issues/#{issue.id}"
    page.find('#content > div:nth-child(1) > a.icon.icon-edit').click
    sleep(0.2)
    expect(page).not_to have_selector('div#template_area select#issue_template')
  end

  context 'Have note template' do
    given(:expected_note_description) { 'Note Template desctiption' }

    before do
      NoteTemplate.create(project_id: project.id, tracker_id: tracker.id,
                          name: 'Note Template name', description: expected_note_description, enabled: true)
    end

    scenario 'Template for note exists' do
      visit_update_issue(user)
      issue = Issue.last
      visit "/issues/#{issue.id}"
      page.find('#content > div:nth-child(1) > a.icon.icon-edit').click
      sleep(0.2)
      expect(page).to have_selector('a#link_template_issue_notes_dialog')

      page.find('a#link_template_issue_notes_dialog').click
      wait_for_ajax

      page.find('#template_issue_notes_dialog table tr:first-child > td:nth-child(3) > a.template-update-link').click
      wait_for_ajax

      expect(issue_note.value).to eq expected_note_description
    end
  end

  context 'Have multiple note templates' do
    background do
      FactoryBot.rewind_sequences
      FactoryBot.create_list(:note_template, 3,
        project_id: project.id, tracker_id: tracker.id, visibility: :open, enabled: true
      )
    end

    scenario 'List of template for note on popup should be in the correct order' do
      template_list = NoteTemplate.visible_note_templates_condition(
        user_id: user.id, project_id: project.id, tracker_id: tracker.id
      ).sorted
      expect(template_list.count).to eq 3

      note_template = template_list.last
      note_template.position = 1
      note_template.save!
      template_list.reload
      #              id: 1, 2, 3    1, 2, 3
      #--------------------------------------
      # change position: 1, 2, 3 to 2, 3, 1

      visit_update_issue(user)
      issue = Issue.last
      visit "/issues/#{issue.id}"
      page.find('#content > div:nth-child(1) > a.icon.icon-edit').click
      sleep(0.2)
      expect(page).to have_selector('a#link_template_issue_notes_dialog')

      page.find('a#link_template_issue_notes_dialog').click
      wait_for_ajax

      page.assert_selector('#template_issue_notes_dialog table.template_list tbody') do |node|
        template_list.each.with_index(1) do |template, idx|
          node.assert_selector(
            "tr:nth-child(#{idx}) td:nth-child(3) a[class~='template-update-link'][data-note-template-id='#{template.id}']"
          )
        end
      end
    end

  end

  context 'Have disabled note templates' do
    background do
      FactoryBot.rewind_sequences
      FactoryBot.create_list(
        :note_template, 3, project_id: project.id, tracker_id: tracker.id, visibility: :open, enabled: false
      )
    end

    scenario 'Disabled Templates would not to be shown.' do
      template_list = NoteTemplate.visible_note_templates_condition(
        user_id: user.id, project_id: project.id, tracker_id: tracker.id
      )
      expect(template_list).to be_empty

      visit_update_issue(user)
      issue = Issue.last
      visit "/issues/#{issue.id}"

      page.find('#content > div:nth-child(1) > a.icon.icon-edit').click
      sleep(0.2)
      expect(page).to have_no_selector('a#link_template_issue_notes_dialog')
    end
  end

  context 'Have global note template' do
    given(:expected_note_description) { 'Global Note Template desctiption' }
    before do
      Setting.send 'plugin_redmine_issue_templates=', 'apply_global_template_to_all_projects' => 'false'
      GlobalNoteTemplate.create(tracker_id: tracker.id, name: 'Global Note Template name', visibility: 2,
                                description: expected_note_description, enabled: true)
    end

    scenario 'No template for note' do
      visit_update_issue(user)
      issue = Issue.last
      visit "/issues/#{issue.id}"
      page.find('#content > div:nth-child(1) > a.icon.icon-edit').click
      sleep(0.2)
      expect(page).not_to have_selector('a#link_template_issue_notes_dialog')
    end

    context 'apply_global_template_to_all_projects is true' do
      before do
        Setting.send 'plugin_redmine_issue_templates=', 'apply_global_template_to_all_projects' => 'true'
      end

      scenario 'One Global template for note' do
        visit_update_issue(user)
        issue = Issue.last
        visit "/issues/#{issue.id}"
        page.find('#content > div:nth-child(1) > a.icon.icon-edit').click
        sleep(0.2)
        expect(page).to have_selector('a#link_template_issue_notes_dialog')

        page.find('a#link_template_issue_notes_dialog').click

        wait_for_ajax
        template_rows = page.find('div#template_issue_notes_dialog table > tbody')

        expect(page).to have_selector('div#template_issue_notes_dialog')
        expect(template_rows).to have_selector('tr:first-child > td:nth-child(3) > a.template-global')

        template_rows.find('tr:first-child > td:nth-child(3) > a.template-global.template-update-link').click
        wait_for_ajax

        expect(issue_note.value).to eq expected_note_description
      end
    end
  end

  context 'Have multiple global note templates' do
    background do
      FactoryBot.rewind_sequences
      FactoryBot.create_list(:global_note_template, 3,
        tracker_id: tracker.id, visibility: :open, enabled: true, project_ids: [project.id]
      )
    end

    scenario 'List of global template for note on popup should be in the correct order' do
      template_list = GlobalNoteTemplate.visible_note_templates_condition(
        user_id: user.id, project_id: project.id, tracker_id: tracker.id
      ).sorted
      expect(template_list.count).to eq 3

      note_template = template_list.last
      note_template.position = 1
      note_template.save!
      template_list.reload
      #              id: 1, 2, 3    1, 2, 3
      #--------------------------------------
      # change position: 1, 2, 3 to 2, 3, 1

      visit_update_issue(user)
      issue = Issue.last
      visit "/issues/#{issue.id}"
      page.find('#content > div:nth-child(1) > a.icon.icon-edit').click
      sleep(0.2)
      expect(page).to have_selector('a#link_template_issue_notes_dialog')

      page.find('a#link_template_issue_notes_dialog').click
      wait_for_ajax

      page.assert_selector('#template_issue_notes_dialog table.template_list tbody') do |node|
        template_list.each.with_index(1) do |template, idx|
          node.assert_selector(
            "tr:nth-child(#{idx}) td:nth-child(3) a[class~='template-update-link'][class~='template-global'][data-note-template-id='#{template.id}']"
          )
        end
      end
    end
  end

  context 'Have disabled global note templates' do
    before do
      Setting.send 'plugin_redmine_issue_templates=', 'apply_global_template_to_all_projects' => 'true'
      create_list(
        :global_note_template, 3, tracker_id: tracker.id, name: 'Global Note Template name', visibility: 2, enabled: false
      )
    end

    scenario 'Disabled global note templates would not be show' do
      template_list = GlobalNoteTemplate.visible_note_templates_condition(
        user_id: user.id, project_id: project.id, tracker_id: tracker.id
      )
      expect(template_list).to be_empty

      visit_update_issue(user)
      issue = Issue.last
      visit "/issues/#{issue.id}"
      page.find('#content > div:nth-child(1) > a.icon.icon-edit').click
      sleep(0.2)
      expect(page).to have_no_selector('a#link_template_issue_notes_dialog')
    end
  end

  private

  def visit_update_issue(user)
    user.update_attribute(:admin, false)
    log_user(user.login, user.login)
  end
end
