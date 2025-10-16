# frozen_string_literal: true

require_relative '../spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../support/controller_helper')

RSpec.configure do |c|
  c.include ControllerHelper
end

RSpec.describe 'Global Note Template', type: :request do
  let(:user) { FactoryBot.create(:user, login: 'test-manager', password: 'password', language: 'en', admin: true) }
  let(:tracker) { FactoryBot.create(:tracker, :with_default_status) }
  let(:target_template_name) { 'Global Note template name' }
  let(:target_template) { GlobalNoteTemplate.last }

  before do
    # do nothing
  end

  it 'show global note template list' do
    login_request(user.login, 'password')
    get '/global_note_templates'
    expect(response.status).to eq 200

    get '/global_note_templates/new'
    expect(response.status).to eq 200
  end

  it 'create global note template and load' do
    login_request(user.login, 'password')
    post '/global_note_templates',
         params: { global_note_template:
           { tracker_id: tracker.id, name: target_template_name,
             description: 'Global Note template description', memo: 'Test memo', enabled: 1 } }
    expect(response).to have_http_status(302)

    post '/note_templates/load', params: { note_template: { note_template_id: target_template.id, template_type: 'global' } }
    json = JSON.parse(response.body)
    expect(target_template.name).to eq(json['note_template']['name'])
  end

  it 'create global note template with roles visibility' do
    login_request(user.login, 'password')

    expected_roles = FactoryBot.create_list(:role, 2)
    post '/global_note_templates',
         params: { global_note_template:
           { tracker_id: tracker.id, name: target_template_name,
             description: 'Global Note template description', memo: 'Test memo', enabled: 1,
             visibility: 'roles', role_ids: expected_roles.map(&:id) } }
    expect(response).to have_http_status(302)

    expect(target_template.visibility).to eq('roles')
    expect(target_template.roles.count).to eq(2)
    expect(target_template.roles.map(&:id)).to match_array(expected_roles.map(&:id))
    expect(GlobalNoteVisibleRole.where(global_note_template_id: nil).count).to eq(0)
  end

  context 'update global note template' do
    context 'when visibility changes from open to roles' do
      it 'changes visibility to roles' do
        login_request(user.login, 'password')
        expected_roles = FactoryBot.create_list(:role, 2)
        target = FactoryBot.create(:global_note_template, { tracker_id: tracker.id, visibility: 'open' })
        patch '/global_note_templates/' + target.id.to_s,
              params: { global_note_template:
                { tracker_id: tracker.id, name: target_template_name,
                  description: 'Global Note template description', memo: 'Test memo', enabled: 1,
                  visibility: 'roles', role_ids: expected_roles.map(&:id) } }
        expect(response).to have_http_status(302)

        expect(target_template.visibility).to eq('roles')
        expect(target_template.roles.count).to eq(2)
        expect(target_template.roles.map(&:id)).to match_array(expected_roles.map(&:id))
        expect(GlobalNoteVisibleRole.where(global_note_template_id: nil).count).to eq(0)
      end
    end

    context 'when visibility changes from roles to open' do
      it 'changes visibility to open' do
        login_request(user.login, 'password')
        roles = FactoryBot.create_list(:role, 2)
        target = FactoryBot.create(:global_note_template, { tracker_id: tracker.id, visibility: 'roles', role_ids: roles.map(&:id) })
        patch '/global_note_templates/' + target.id.to_s,
              params: { global_note_template:
                { tracker_id: tracker.id, name: target_template_name,
                  description: 'Global Note template description', memo: 'Test memo', enabled: 1,
                  visibility: 'open' } }
        expect(response).to have_http_status(302)

        target.reload
        expect(target.visibility).to eq('open')
        expect(target.roles.count).to eq(0)
      end
    end

    context 'when changes role_ids' do
      it 'updates roles' do
        login_request(user.login, 'password')
        expected_roles = FactoryBot.create_list(:role, 3)
        target = FactoryBot.create(:global_note_template, { tracker_id: tracker.id, visibility: 'roles', role_ids: FactoryBot.create_list(:role, 2).map(&:id) })
        patch '/global_note_templates/' + target.id.to_s,
              params: { global_note_template:
                { tracker_id: tracker.id, name: target_template_name,
                  description: 'Global Note template description', memo: 'Test memo', enabled: 1,
                  visibility: 'roles', role_ids: expected_roles.map(&:id) } }
        expect(response).to have_http_status(302)

        target.reload
        expect(target.visibility).to eq('roles')
        expect(target.roles.count).to eq(3)
        expect(target.roles.map(&:id)).to match_array(expected_roles.map(&:id))
        expect(GlobalNoteVisibleRole.where(global_note_template_id: nil).count).to eq(0)
      end
    end
  end
end
