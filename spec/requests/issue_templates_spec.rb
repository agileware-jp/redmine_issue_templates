# frozen_string_literal: true

require_relative '../spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../support/controller_helper')

RSpec.configure do |c|
  c.include ControllerHelper
end

RSpec.describe 'Issue Template', type: :request do
  let(:user) { FactoryBot.create(:user, login: 'test-manager', password: 'password', language: 'en') }
  let(:project) { FactoryBot.create(:project, trackers: FactoryBot.create_list(:tracker, 3, :with_default_status), enabled_module_names: %w[issue_templates]) }

  let!(:first_template) { FactoryBot.create(:issue_template, title: 'First template', description: 'First template description', project: project, tracker: project.trackers.first) }
  let!(:second_template) { FactoryBot.create(:issue_template, title: 'Second template', project: project, tracker: project.trackers.first) }
  let!(:third_template) { FactoryBot.create(:issue_template, title: 'Third template', project: project, tracker: project.trackers.first) }
  let!(:other_tracker_template) { FactoryBot.create(:issue_template, title: 'Other tracker template', project: project, tracker: project.trackers.last) }

  before do
    FactoryBot.create(:member, roles: [role], principal: user, project: project)
    login_request(user.login, 'password')
  end

  describe 'GET /projects/:project_id/issue_templates/orphaned_templates' do
    context 'with permissions' do
      let(:role) { Role.find_by(name: 'Issue templates viewer') || FactoryBot.create(:role, :issue_templates_viewer) }

      it 'returns ok' do
        get orphaned_templates_project_issue_templates_path(project)

        expect(response).to have_http_status :ok
      end
    end

    context 'without permissions' do
      let(:role) { Role.find_by(name: 'No issue templates permission') || FactoryBot.create(:role, :no_issue_templates_permission) }

      it 'returns forbidden' do
        get orphaned_templates_project_issue_templates_path(project)

        expect(response).to have_http_status :forbidden
      end
    end
  end

  describe 'GET /projects/:project_id/issue_templates/list_templates?issue_tracker_id=' do
    context 'with permission' do
      let(:role) { Role.find_by(name: 'Issue templates editor') || FactoryBot.create(:role, :issue_templates_editor) }

      it 'returns templates' do
        get list_templates_project_issue_templates_path(project, issue_tracker_id: project.trackers.first.id)

        expect(response.body).to include('First template')
        expect(response.body).to include('Second template')
        expect(response.body).to include('Third template')
        expect(response.body).not_to include('Other tracker template')
      end
    end

    context 'without permission' do
      let(:role) { Role.find_by(name: 'No issue templates permission') || FactoryBot.create(:role, :no_issue_templates_permission) }

      it 'returns forbidden' do
        get list_templates_project_issue_templates_path(project, issue_tracker_id: project.trackers.first.id)

        expect(response).to have_http_status :forbidden
      end
    end
  end

  describe 'PUT /projects/:project_id/issue_templates/:id' do
    context 'with permission' do
      let(:role) { Role.find_by(name: 'Issue templates editor') || FactoryBot.create(:role, :issue_templates_editor) }

      it 'updates position' do
        positions = IssueTemplate.where(project: project, tracker: project.trackers.first).order(:id).pluck(:position).to_a
        put project_issue_template_path(project, IssueTemplate.where(project: project, tracker: project.trackers.first).order(:id).first), params: { issue_template: { position: positions[2] } }

        expect(response).to have_http_status :found
        expect(IssueTemplate.where(project: project, tracker: project.trackers.first).order(:id).pluck(:position).to_a).to eq([positions[2], positions[0], positions[1]])
      end
    end

    context 'without permission' do
      let(:role) { Role.find_by(name: 'No issue templates permission') || FactoryBot.create(:role, :no_issue_templates_permission) }

      it 'returns forbidden' do
        put project_issue_template_path(project, IssueTemplate.where(project: project, tracker: project.trackers.first).order(:id).first), params: { issue_template: { position: 3 } }

        expect(response).to have_http_status :forbidden
      end
    end
  end

  describe 'POST /issue_templates/load?project_id=' do
    let(:role) { Role.find_by(name: 'Issue templates editor') || FactoryBot.create(:role, :issue_templates_editor) }

    it 'returns template' do
      post load_issue_templates_path(project_id: project.id), params: { template_id: first_template.id }

      expect(JSON.parse(response.body)["issue_template"]["description"]).to eq('First template description')
    end
  end
end
