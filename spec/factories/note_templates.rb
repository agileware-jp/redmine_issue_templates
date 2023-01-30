FactoryBot.define do
  factory :note_template do
    association :project
    association :tracker
    author_id { 1 }
    sequence(:name) { |n| "note-template-name: #{n}" }
    sequence(:description) { |n| "note-template-description: #{n}" }
    sequence(:memo) { |n| "note-template-memo: #{n}" }
    enabled { true }
    sequence(:position) { |n| n }
    visibility { NoteTemplate.visibilities[:open] }
  end
end
