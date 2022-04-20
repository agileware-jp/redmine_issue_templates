# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../rails_helper')
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../support/login_helper')

feature 'Templates can be reorder via drag and drop', js: true do
  include LoginHelper
  given(:user) { FactoryBot.create(:user, :password_same_login, login: 'manager', language: 'en', admin: false) }
  given(:project) { create(:project_with_enabled_modules) }
  given(:tracker) { FactoryBot.create(:tracker, :with_default_status) }
  given(:role) { FactoryBot.create(:role, :manager_role) }
  given(:table) { page.find('table.list.issues.table-sortable:first-of-type > tbody') }

  background do
    project.trackers << tracker
    assign_template_priv(role, add_permission: :show_issue_templates)
    assign_template_priv(role, add_permission: :edit_issue_templates)
    member = Member.new(project: project, user_id: user.id)
    member.member_roles << MemberRole.new(role: role)
    member.save
  end

  scenario 'Can drag and drop on Issue Templates' do
    FactoryBot.create_list(:issue_template, 4, project_id: project.id, tracker_id: tracker.id)

    visit_template_list(user)

    first_target = table.find('tr:nth-child(1) > td.buttons > span')
    last_target = table.find('tr:nth-child(4) > td.buttons > span')

    # change id: 1, 2, 3, 4 to 4, 1, 2, 3
    expect do
      first_target.drag_to(last_target)
      wait_for_ajax
    end.to change {
             IssueTemplate.order(:id).pluck(:position).to_a
           }.from([1, 2, 3, 4]).to([4, 1, 2, 3])

    # change id: 4, 1, 2, 3 to 3, 1, 4, 2
    second_target = table.find('tr:nth-child(2) > td.buttons > span')
    last_target = table.find('tr:nth-child(4) > td.buttons > span')

    expect do
      second_target.drag_to(last_target)
      wait_for_ajax
    end.to change {
             IssueTemplate.order(:id).pluck(:position).to_a
           }.from([4, 1, 2, 3]).to([3, 1, 4, 2])
  end

  scenario 'Can drag and drop on Note Templates' do
    FactoryBot.create_list(:note_template, 4, project_id: project.id, tracker_id: tracker.id)

    visit_note_template_list(user)

    first_target = table.find('tr:nth-child(1) > td.buttons > span')
    last_target = table.find('tr:nth-child(4) > td.buttons > span')

    # change id: 1, 2, 3, 4 to 4, 1, 2, 3
    expect do
      first_target.drag_to(last_target)
      wait_for_ajax
    end.to change {
             NoteTemplate.reorder(:id).pluck(:position).to_a
           }.from([1, 2, 3, 4]).to([4, 1, 2, 3])

    # change id: 4, 1, 2, 3 to 3, 1, 4, 2
    second_target = table.find('tr:nth-child(2) > td.buttons > span')
    last_target = table.find('tr:nth-child(4) > td.buttons > span')

    expect do
      second_target.drag_to(last_target)
      wait_for_ajax
    end.to change {
             NoteTemplate.reorder(:id).pluck(:position).to_a
           }.from([4, 1, 2, 3]).to([3, 1, 4, 2])
  end

  scenario 'Can drag and drop on Global Issue Templates' do
    FactoryBot.create_list(:global_issue_template, 4, tracker_id: tracker.id)

    visit_global_template_list(user)

    first_target = table.find('tr:nth-child(1) > td.buttons > span')
    last_target = table.find('tr:nth-child(4) > td.buttons > span')

    # change id: 1, 2, 3, 4 to 4, 1, 2, 3
    expect do
      first_target.drag_to(last_target)
      wait_for_ajax
    end.to change {
             GlobalIssueTemplate.reorder(:id).pluck(:position).to_a
           }.from([1, 2, 3, 4]).to([4, 1, 2, 3])

    # change id: 4, 1, 2, 3 to 3, 1, 4, 2
    second_target = table.find('tr:nth-child(2) > td.buttons > span')
    last_target = table.find('tr:nth-child(4) > td.buttons > span')

    expect do
      second_target.drag_to(last_target)
      wait_for_ajax
    end.to change {
             GlobalIssueTemplate.reorder(:id).pluck(:position).to_a
           }.from([4, 1, 2, 3]).to([3, 1, 4, 2])
  end

  private

  def visit_template_list(user)
    # TODO: If does not user update, authentication is failed. This is workaround.
    user.update_attribute(:admin, false)
    log_user(user.login, user.password)
    visit "/projects/#{project.identifier}/issue_templates"
  end

  def visit_note_template_list(user)
    # TODO: If does not user update, authentication is failed. This is workaround.
    user.update_attribute(:admin, false)
    log_user(user.login, user.password)
    visit "/projects/#{project.identifier}/note_templates"
  end

  def visit_global_template_list(user)
    # Prevent to call User#deliver_security_notification when user is created.
    expect(user).to receive(:deliver_security_notification).and_return(true)
    user.update_attribute(:admin, true)
    log_user(user.login, user.password)
    visit "/global_issue_templates"
  end

  def offset_array(from, to)
    from_location = element_position(from)
    to_location = element_position(to)

    [to_location[0] - from_location[0], to_location[1] - from_location[1]]
  end

  def element_position(element)
    Capybara.evaluate_script <<-RUBY
      function() {
        var element = document.evaluate('#{element.path}', document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
        var rect = element.getBoundingClientRect();
        return [rect.left, rect.top];
      }();
    RUBY
  end
end
