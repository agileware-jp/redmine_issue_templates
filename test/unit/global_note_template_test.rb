# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class GlobalNoteTemplateTest < ActiveSupport::TestCase
  fixtures :projects, :users, :trackers, :roles

  def setup; end
  def teardown; end

  def test_create_should_require_tracker
    template = GlobalNoteTemplate.new(name: 'GlobalNoteTemplate1', visibility: 'open')
    assert_no_difference 'GlobalNoteTemplate.count' do
      assert_raises ActiveRecord::RecordInvalid do
        template.save!
      end
    end
    assert_equal ['Tracker cannot be blank'], template.errors.full_messages
  end
end
