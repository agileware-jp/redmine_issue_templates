require File.expand_path('../test_helper', __dir__)
require 'minitest/autorun'

class GlobalNoteTemplatesControllerTest < Redmine::ControllerTest
  fixtures :projects, :users, :trackers, :global_note_templates

  include Redmine::I18n

  def setup
    @request.session[:user_id] = 1 # Admin
    @request.env['HTTP_REFERER'] = '/'
    @project = Project.find(1)
    EnabledModule.create! project_id: 1, name: 'issue_templates' unless @project.module_enabled?('issue_templates')
  end

  def test_should_require_admin
    @request.session[:user_id] = 2 # non-Admin

    get :index
    assert_response 403

    get :new
    assert_response 403

    get :show, params: { id: 1 }
    assert_response 403

    post :create, params: { global_note_template: { description: 'Test.' } }
    assert_response 403

    patch :update, params: { id: 1, global_note_template: { description: 'Test.' } }
    assert_response 403

    delete :destroy, params: { id: 1 }
    assert_response 403
  end

  def test_get_index
    get :index
    assert_response :success
    assert_select 'div.template_box h3.template_tracker', 'Bug'
  end

  def test_update_template
    put :update, params: { id: 1, global_note_template: { description: 'Update Test Global template2' } }
    t = GlobalNoteTemplate.find(1)
    assert_redirected_to controller: 'global_note_templates', action: 'show', id: 1
    assert_equal 'Update Test Global template2', t.description
  end

  def test_update_template_with_empty_name
    put :update, params: { id: 1, global_note_template: { name: '' } }
    assert_response :success
    t = GlobalNoteTemplate.find(1)
    assert_not_equal '', t.name

    # render :show
    assert_select 'h2.global_note_template', "#{l(:global_note_templates)}: #1"
    # Error message should be displayed.
    assert_select 'div#errorExplanation', { count: 1, text: /Template name cannot be blank/ }, @response.body.to_s
  end

  def test_destroy_template
    GlobalNoteTemplate.update_all(enabled: false)
    assert_difference ->{ GlobalNoteTemplate.count }, -1 do
      delete :destroy, params: { id: 1 }
      assert_redirected_to controller: 'global_note_templates', action: 'index'
    end
    assert_raise(ActiveRecord::RecordNotFound) { GlobalNoteTemplate.find(1) }
  end

  def test_new_template
    get :new
    assert_response :success
  end

  def test_create_template
    assert_difference ->{ GlobalNoteTemplate.count } do
      post :create, params: { global_note_template: { name: 'Global Template newtitle for creation test',
                                                     description: 'Global Template description for creation test',
                                                     tracker_id: 1, enabled: 1, author_id: 1 } }
      assert_response :redirect
    end

    assert_response :redirect

    assert template = GlobalNoteTemplate.order(id: :desc).first
    assert_equal('Global Template newtitle for creation test', template.name)
    assert_equal('Global Template description for creation test', template.description)
    assert_equal(1, template.tracker.id)
    assert_equal(1, template.author.id)
  end

  def test_create_template_fail
    assert_no_difference 'GlobalNoteTemplate.count' do
      # when title blank, validation bloks to save.
      post :create, params: { global_note_template: { name: '', description: 'description', tracker_id: 1, enabled: 1, author_id: 1 } }
      assert_response :success
    end

    # render :new
    assert_select 'h2', text: "#{l(:global_note_templates)} / #{l(:button_add)}"
    # Error message should be displayed.
    assert_select 'div#errorExplanation', { count: 1, text: /Template name cannot be blank/ }, @response.body.to_s
  end
end
