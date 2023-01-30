# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class NoteTemplateTest < ActiveSupport::TestCase
  fixtures :projects, :users, :trackers, :roles,
           :members, :member_roles,
           :note_templates, :note_visible_roles

  def setup
    tracker = Tracker.first
    params = {
      author: User.first, project: Project.first,
      tracker: tracker
    }.merge(
      name: "Note Template name for Tracker #{tracker.name}.",
      description: "Note Template description for Tracker #{tracker.name}.",
      memo: "Note Template memo for Tracker #{tracker.name}.",
      enabled: true
    )
    @template = NoteTemplate.create(params)
  end

  def teardown; end

  def test_truth
    assert_kind_of NoteTemplate, @template
  end

  def test_template_enabled
    assert_equal true, @template.enabled?

    @template.enabled = false
    @template.save!
    assert_equal false, @template.enabled?
  end

  def test_sort_by_position
    a = NoteTemplate.new(name: 'Template1', position: 2, project_id: 1, tracker_id: 1)
    b = NoteTemplate.new(name: 'Template2', position: 1, project_id: 1, tracker_id: 1)
    assert_equal [b, a], [a, b].sort
  end

  def test_visibility_with_success
    a = NoteTemplate.create(name: 'Template1', position: 2, project_id: 1, tracker_id: 1,
                            visibility: 'roles', role_ids: [Role.first.id])
    assert_equal 1, NoteTemplate.visibilities[a.visibility]

    a.visibility = 'mine'
    a.save
    assert_equal 0, NoteTemplate.visibilities[a.visibility]
  end

  def test_visibility_without_role_ids
    # When enable validation: Raise ActiveRecord::RecordInvalid
    e = assert_raises ActiveRecord::RecordInvalid do
      NoteTemplate.create!(name: 'Template1', position: 2, project_id: 1, tracker_id: 1,
                           visibility: 'roles', description: 'description1')
    end

    # Check error message.
    assert_equal 'Validation failed: Role ids cannot be blank', e.message
  end

  def test_visibility_from_mine_to_roles
    a = NoteTemplate.create(name: 'Template1', position: 2, project_id: 1, tracker_id: 1,
                            visibility: 'mine')
    a.visibility = 'roles'

    # When skip validation: Raise: NoteTemplate::NoteTemplateError: Please select at least one role.
    e = assert_raises NoteTemplate::NoteTemplateError do
      a.save(validate: false)
    end

    # Check error message.
    assert_equal 'Please select at least one role.', e.message
  end

  def test_create_should_require_tracker
    template = NoteTemplate.new(name: 'NoteTemplate1', project_id: 1, visibility: 'open', description: 'description1')
    assert_no_difference 'NoteTemplate.count' do
      assert_raises ActiveRecord::RecordInvalid do
        template.save!
      end
    end
    assert_equal ['Tracker cannot be blank'], template.errors.full_messages
  end

  def test_required_attributes_should_be_validated
    template = NoteTemplate.find(1)
    {
      project_id: nil,
      name: ' ',
      tracker: nil,
      description: " \n\n ",
    }.each do |attr, val|
      template.reload
      template.__send__("#{attr}=", val)

      assert_raises ActiveRecord::RecordInvalid do
        template.save!
      end

      assert_includes template.errors[attr], 'cannot be blank'
    end
  end

  def test_loadable_with_admin_user
    user = User.find_by_login('admin')
    assert_equal true, user.admin?
    NoteTemplate.all.each do |template|
      assert_equal true, template.loadable?(user_id: user.id)
    end
  end

  def test_loadable_with_visibility_open
    template = NoteTemplate.find(4)

    assert_equal true, template.open?
    assert_equal false, template.mine?
    assert_equal false, template.roles?

    User.logged.where(admin: false).each do |user|
      assert_equal true, template.loadable?(user_id: user.id)
    end
  end

  def test_loadable_with_visibility_mine
    template = NoteTemplate.find(1)

    assert_equal false, template.open?
    assert_equal true, template.mine?
    assert_equal false, template.roles?

    jsmith = User.find_by_login('jsmith')
    assert_equal jsmith, template.author
    assert_equal true, template.loadable?(user_id: jsmith.id)

    assert_equal false, template.loadable?(user_id: User.find_by_login('dlopper').id)
  end

  def test_loadable_with_visibility_roles
    template = NoteTemplate.find(3)

    assert_equal false, template.open?
    assert_equal false, template.mine?
    assert_equal true, template.roles?

    assert_equal [2], template.roles.ids.sort

    project = template.project

    jsmith = User.find_by_login('jsmith')
    assert_equal [1], jsmith.roles_for_project(project).collect(&:id).sort
    assert_equal false, template.loadable?(user_id: jsmith.id)

    dlopper = User.find_by_login('dlopper')
    assert_equal [2], dlopper.roles_for_project(project).collect(&:id).sort
    assert_equal true, template.loadable?(user_id: dlopper.id)
  end
end
