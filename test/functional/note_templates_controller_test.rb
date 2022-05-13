require File.expand_path('../test_helper', __dir__)
require 'minitest/autorun'

class NoteTemplatesControllerTest < Redmine::ControllerTest
  fixtures :projects, :enabled_modules,
           :users, :roles,
           :members, :member_roles,
           :trackers, :projects_trackers,
           :note_templates, :note_visible_roles

  def setup
    @request.session[:user_id] = 2  # jsmith
    @request.env['HTTP_REFERER'] = '/'
    # Enabled Template module
    @project = Project.find(1)
    @project.enabled_modules << EnabledModule.new(name: 'issue_templates')
    @project.save!

    # Set default permission: show template
    Role.find(1).add_permission! :show_issue_templates
  end

  def test_index_with_non_existing_project_should_be_not_found
    # set non existing project
    get :index, params: { project_id: 100 }
    assert_response :not_found
  end

  def test_index_without_show_permission_should_be_forbidden
    Role.find(1).remove_permission! :show_issue_templates
    get :index, params: { project_id: 1 }
    assert_response :forbidden
  end

  def test_index_with_normal_should_be_success
    get :index, params: { project_id: 1 }
    assert_response :success
  end

  def test_index_with_admin_logged_in_should_appear_all_note_templates
    @request.session[:user_id] = 1  # admin

    ids = NoteTemplate.reorder(id: :asc).where(project_id: 1).pluck(:id)
    assert_equal [1, 2, 3, 4, 5], ids

    get :index, params: { project_id: 1 }
    assert_response :success

    assert_select 'table.template_list tbody tr.note_template' do
      ids.each do |id|
        assert_select 'td a[href=?]', "/projects/ecookbook/note_templates/#{id}", count: 1
      end
    end
  end

  def test_index_should_appear_note_templates_with_open_visibility
    ids = NoteTemplate.reorder(id: :asc).where(project_id: 1).open.pluck(:id)
    assert_equal [4], ids

    get :index, params: { project_id: 1 }
    assert_response :success

    assert_select 'table.template_list tbody tr.note_template' do
      ids.each do |id|
        assert_select 'td a[href=?]', "/projects/ecookbook/note_templates/#{id}", count: 1
      end
    end
  end

  def test_index_with_author_logged_in_should_appear_note_templates_with_mine_visibility
    user_id = 3 # dlopper
    @request.session[:user_id] = user_id
    Role.find(2).add_permission! :show_issue_templates

    ids = NoteTemplate.reorder(id: :asc).where(project_id: 1).mine_condition(user_id).pluck(:id)
    assert_equal [5], ids

    get :index, params: { project_id: 1 }
    assert_response :success

    assert_select 'table.template_list tbody tr.note_template' do
      ids.each do |id|
        assert_select 'td a[href=?]', "/projects/ecookbook/note_templates/#{id}", count: 1
      end
    end
  end

  def test_index_should_appear_note_templates_with_roles_visibility
    ids = NoteTemplate.reorder(id: :asc).where(project_id: 1).where(visibility: :roles).pluck(:id)
    assert_equal [2, 3], ids

    @request.session[:user_id] = 2  # jsmith
    Role.find(1).add_permission! :show_issue_templates

    get :index, params: { project_id: 1 }
    assert_response :success

    assert_select 'table.template_list tbody tr.note_template' do
      assert_select 'td a[href=?]', "/projects/ecookbook/note_templates/2", count: 1
      assert_select 'td a[href=?]', "/projects/ecookbook/note_templates/3", count: 0
    end

    @request.session[:user_id] = 3  # dlopper
    Role.find(2).add_permission! :show_issue_templates

    get :index, params: { project_id: 1 }
    assert_response :success

    assert_select 'table.template_list tbody tr.note_template' do
      assert_select 'td a[href=?]', "/projects/ecookbook/note_templates/2", count: 1
      assert_select 'td a[href=?]', "/projects/ecookbook/note_templates/3", count: 1
    end
  end
end
