# frozen_string_literal: true

require_relative '../spec_helper'

describe GlobalNoteTemplate do
  let(:tracker) { FactoryBot.create(:tracker, :with_default_status) }
  let!(:note_template) { FactoryBot.create(:global_note_template, tracker_id: tracker.id, position: 1) }
  let!(:note_template2) { FactoryBot.create(:global_note_template, tracker_id: tracker.id, position: 2) }
  let!(:note_template3) { FactoryBot.create(:global_note_template, tracker_id: tracker.id, position: 3) }

  it 'Instance of GlobalNoteTemplate' do
    expect(note_template).to be_an_instance_of(GlobalNoteTemplate)
  end

  describe 'scope: .sorted' do
    it 'do sort by position correctly' do
      expect([note_template, note_template2, note_template3]).to eq GlobalNoteTemplate.sorted
      expect(GlobalNoteTemplate.sorted.first).to eq note_template
    end

    it 'do sort by position correctly after update' do
      note_template.update(position: GlobalNoteTemplate.count)
      expect(GlobalNoteTemplate.sorted).to eq [note_template2, note_template3, note_template]
    end
  end

  it 'can be deleted even though some projects bound' do
    note_template_with_project = create(:global_note_template, tracker_id: tracker.id, position: 4, enabled: false)
    note_template_with_project.projects << create(:project) << create(:project) << create(:project)

    expect(GlobalNoteTemplate.where(id: note_template_with_project.id)).not_to be_empty
    note_template_with_project.destroy
    expect(GlobalNoteTemplate.where(id: note_template_with_project.id)).to be_empty
  end
end
