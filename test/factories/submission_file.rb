# frozen_string_literal: true

FactoryBot.define do
  factory :submission_file do
    association :artist_submission

    created_at_on_site { Time.current }
    direct_url { "https://localhost/image.webp" }
    file_identifier { "" }
    content_type { "image/png" }
    width { 1_000 }
    height { 1_000 }
    size { 100.kilobytes }

    before(:create) do |submission_file|
      submission_file.attach_original!(file_fixture("1.webp").open)
    end
  end
end
