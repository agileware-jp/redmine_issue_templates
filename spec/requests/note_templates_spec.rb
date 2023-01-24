# frozen_string_literal: true

require_relative '../spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../support/controller_helper')

RSpec.configure do |c|
  c.include ControllerHelper
end

RSpec.describe 'Note Template', type: :request do
  let(:user) { FactoryBot.create(:user, :password_same_login, login: 'test-manager', language: 'en', admin: false) }
  let(:project) { FactoryBot.create(:project_with_enabled_modules) }
  let(:tracker) { FactoryBot.create(:tracker, :with_default_status) }
  let(:role) { FactoryBot.create(:role, :manager_role) }
  let(:target_template) { NoteTemplate.last }

  before do
    project.trackers << tracker
    assign_template_priv(role, add_permission: :show_issue_templates)
    assign_template_priv(role, add_permission: :edit_issue_templates)
    member = Member.new(project: project, user_id: user.id)
    member.member_roles << MemberRole.new(role: role)
    member.save
  end

  it 'show note template list' do
    login_request(user.login, user.login)
    get "/projects/#{project.identifier}/note_templates"
    expect(response.status).to eq 200

    get "/projects/#{project.identifier}/note_templates/new"
    expect(response.status).to eq 200
  end

  it 'create note template and load' do
    login_request(user.login, user.login)
    post "/projects/#{project.identifier}/note_templates",
         params: { note_template:
           { tracker_id: tracker.id, name: 'Note template name',
             description: 'Note template description', memo: 'Test memo', enabled: 1 } }
    expect(response).to have_http_status(302)

    post '/note_templates/load', params: { note_template: { note_template_id: target_template.id } }
    json = JSON.parse(response.body)
    expect(target_template.name).to eq(json['note_template']['name'])
  end

  context 'When editing an issue' do
    before do
      3.times do |idx|
        NoteTemplate.create(project_id: project.id, tracker_id: tracker.id,
          name: "Note Template name #{idx + 1}", description: 'Note Template desctiption',
          enabled: true, visibility: :open
        )
      end
    end

    it 'Note templates list in the popup dialog displays in order' do
      login_request(user.login, user.login)

      template_list = NoteTemplate.visible_note_templates_condition(
        user_id: user.id, project_id: project.id, tracker_id: tracker.id
      ).sorted
      expect(template_list.count).to eq 3

      note_template = template_list.last
      note_template.position = 1
      note_template.save!

      template_list.reload

      get list_templates_note_templates_path(project_id: project.id, tracker_id: tracker.id), xhr: true

      expect(response).to have_http_status(200)
      assert_select('table.template_list') do
        template_list.each.with_index(1) do |template, idx|
          assert_select(
            "tbody tr:nth-child(#{idx}) td:nth-child(3) a[class~='template-update-link'][data-note-template-id='#{template.id}']"
          )
        end
      end
    end
  end
end
