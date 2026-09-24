# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../rails_helper')
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../support/login_helper')

feature 'Templates can be reorder via drag and drop', js: true do
  include LoginHelper
  given(:user) { FactoryBot.create(:user, login: 'manager', password: 'password', language: 'en', admin: false) }
  given(:project) { create(:project_with_enabled_modules) }
  given(:tracker) { FactoryBot.create(:tracker, :with_default_status) }
  given(:role) { FactoryBot.create(:role, :manager_role) }
  # `.ui-sortable` is added once positionedItems() has initialized the table,
  # so finding it also waits until drag and drop is actually available.
  given(:table) { page.find('table.list.issues.table-sortable:first-of-type > tbody.ui-sortable') }

  background do
    project.trackers << tracker
    assign_template_priv(role, add_permission: :show_issue_templates)
    assign_template_priv(role, add_permission: :edit_issue_templates)
    member = Member.new(project: project, user_id: user.id)
    member.member_roles << MemberRole.new(role: role)
    member.save
  end

  scenario 'Can drag and drop on Issue Templates' do
    templates = FactoryBot.create_list(:issue_template, 4, project_id: project.id, tracker_id: tracker.id)

    log_user(user.login, user.password)
    expect(page).to have_current_path(my_page_path, wait: 5)

    visit project_issue_templates_path(project)
    expect(page).to have_current_path(project_issue_templates_path(project), wait: 5)

    first_target = table.find('tr:nth-child(1) > td.buttons > span')
    last_target = table.find('tr:nth-child(4) > td.buttons > span')

    # change id: 1, 2, 3, 4 to 4, 1, 2, 3
    expect do
      Redmine::VERSION::STRING < '4.2' ?
        page.driver.browser.action.drag_and_drop_by(first_target.native, 0, 90).perform :
        first_target.drag_to(last_target)
      wait_for_reorder(templates, [4, 1, 2, 3])
    end.to change {
             IssueTemplate.order(:id).pluck(:position).to_a
           }.from([1, 2, 3, 4]).to([4, 1, 2, 3])

    # change id: 4, 1, 2, 3 to 3, 1, 4, 2
    second_target = table.find('tr:nth-child(2) > td.buttons > span')
    last_target = table.find('tr:nth-child(4) > td.buttons > span')

    expect do
      Redmine::VERSION::STRING < '4.2' ?
        page.driver.browser.action.drag_and_drop_by(second_target.native, 0, 60).perform :
        second_target.drag_to(last_target)
      wait_for_reorder(templates, [3, 1, 4, 2])
    end.to change {
             IssueTemplate.order(:id).pluck(:position).to_a
           }.from([4, 1, 2, 3]).to([3, 1, 4, 2])
  end

  feature 'Note Templates' do
    background do
      FactoryBot.rewind_sequences
    end

    scenario 'Can drag and drop on Note Templates' do
      templates = FactoryBot.create_list(:note_template, 4, project_id: project.id, tracker_id: tracker.id)

      visit_note_template_list(user)

      first_target = table.find('tr:nth-child(1) > td.buttons > span')
      last_target = table.find('tr:nth-child(4) > td.buttons > span')

      #              id: 1, 2, 3, 4    1, 2, 3, 4
      #--------------------------------------------
      # change position: 1, 2, 3, 4 to 4, 1, 2, 3
      expect do
        Redmine::VERSION::STRING < '4.2' ?
          page.driver.browser.action.drag_and_drop_by(first_target.native, 0, 90).perform :
          first_target.drag_to(last_target)
        wait_for_reorder(templates, [4, 1, 2, 3])
      end.to change {
               NoteTemplate.reorder(:id).pluck(:position).to_a
             }.from([1, 2, 3, 4]).to([4, 1, 2, 3])

      #              id: 1, 2, 3, 4    1, 2, 3, 4
      #--------------------------------------------
      # change position: 4, 1, 2, 3 to 3, 1, 4, 2
      second_target = table.find('tr:nth-child(2) > td.buttons > span')
      last_target = table.find('tr:nth-child(4) > td.buttons > span')

      expect do
        Redmine::VERSION::STRING < '4.2' ?
          page.driver.browser.action.drag_and_drop_by(second_target.native, 0, 60).perform :
          second_target.drag_to(last_target)
        wait_for_reorder(templates, [3, 1, 4, 2])
      end.to change {
               NoteTemplate.reorder(:id).pluck(:position).to_a
             }.from([4, 1, 2, 3]).to([3, 1, 4, 2])
    end

    scenario 'After changing the sort position, Role settings should not change' do
      developer_role = FactoryBot.create(:role)
      template_list =
        FactoryBot.create_list(:note_template, 2,
          project_id: project.id, tracker_id: tracker.id,
          visibility: NoteTemplate.visibilities[:roles],
          role_ids: [role.id, developer_role.id],
        )
      template_list.each(&:reload)

      template1 = template_list.first
      expect(template1.position).to eq(1)
      expect(template1.roles?).to be_truthy
      expect(template1.note_visible_roles.pluck(:role_id)).to eq([role.id, developer_role.id])

      visit_note_template_list(user)

      expect do
        positions = [1, 2]
        5.times do
          first_target = table.find('tr:nth-child(1) > td.buttons > span')
          last_target = table.find('tr:nth-child(2) > td.buttons > span')

          Redmine::VERSION::STRING < '4.2' ?
            page.driver.browser.action.drag_and_drop_by(first_target.native, 0, 30).perform :
            first_target.drag_to(last_target)
          positions.reverse!
          wait_for_reorder(template_list, positions)
        end
      end.to \
        change {
          NoteTemplate.reorder(:id).pluck(:position).to_a
        }.from([1, 2]).to([2, 1])

      template1.reload
      expect(template1.position).to eq(2)
      expect(template1.roles?).to be_truthy
      expect(template1.note_visible_roles.pluck(:role_id)).to eq([role.id, developer_role.id])
    end
  end

  scenario 'Can drag and drop on Global Issue Templates' do
    templates = FactoryBot.create_list(:global_issue_template, 4, tracker_id: tracker.id)

    visit_global_template_list(user)

    first_target = table.find('tr:nth-child(1) > td.buttons > span')
    last_target = table.find('tr:nth-child(4) > td.buttons > span')

    # change id: 1, 2, 3, 4 to 4, 1, 2, 3
    expect do
      Redmine::VERSION::STRING < '4.2' ?
        page.driver.browser.action.drag_and_drop_by(first_target.native, 0, 90).perform :
        first_target.drag_to(last_target)
      wait_for_reorder(templates, [4, 1, 2, 3])
    end.to change {
             GlobalIssueTemplate.reorder(:id).pluck(:position).to_a
           }.from([1, 2, 3, 4]).to([4, 1, 2, 3])

    # change id: 4, 1, 2, 3 to 3, 1, 4, 2
    second_target = table.find('tr:nth-child(2) > td.buttons > span')
    last_target = table.find('tr:nth-child(4) > td.buttons > span')

    expect do
      Redmine::VERSION::STRING < '4.2' ?
        page.driver.browser.action.drag_and_drop_by(second_target.native, 0, 60).perform :
        second_target.drag_to(last_target)
      wait_for_reorder(templates, [3, 1, 4, 2])
    end.to change {
             GlobalIssueTemplate.reorder(:id).pluck(:position).to_a
           }.from([4, 1, 2, 3]).to([3, 1, 4, 2])
  end

  private

  # Wait until the title column shows the templates ordered by the expected
  # positions (positions[i] is the expected position of templates[i]), then wait
  # for the reorder request issued on drop to finish.
  def wait_for_reorder(templates, positions)
    titles = templates.zip(positions).sort_by(&:last).map { |template, _| template_title(template) }
    titles.each_with_index do |title, i|
      expect(table).to have_css("tr:nth-child(#{i + 1}) > td.template_title", exact_text: title, wait: 5)
    end
    wait_for_ajax
  end

  def template_title(template)
    template.is_a?(NoteTemplate) ? template.name : template.title
  end

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
