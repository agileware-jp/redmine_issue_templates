# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class GlobalNoteTemplateTest < ActiveSupport::TestCase
  fixtures :projects, :users, :trackers, :roles, :global_note_templates

  def setup; end
  def teardown; end

  def test_create_should_require_tracker
    template = GlobalNoteTemplate.new(name: 'GlobalNoteTemplate1', visibility: 'open', description: 'description1')
    assert_no_difference 'GlobalNoteTemplate.count' do
      assert_raises ActiveRecord::RecordInvalid do
        template.save!
      end
    end
    assert_equal ['Tracker cannot be blank'], template.errors.full_messages
  end

  def test_required_attributes_should_be_validated
    template = GlobalNoteTemplate.find(1)
    {
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
end
