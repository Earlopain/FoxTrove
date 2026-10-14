FactoryBot.define do
  factory :e6_post do
    association :submission_file

    post_id { 123 }
    post_width { 100 }
    post_height { 100 }
    post_size { 300.kilobytes }
    similarity_score { 95 }
    is_exact_match { false }
    post_json { { "files" => { "original" => { "url" => "https://localhost/image.png" } }, "stats" => { "score" => { "total" => 50 } } } }
    post_is_deleted { false }
    post_score { 50 }
    post_direct_url { "https://localhost/image.png" }

    after(:create) do |e6_post|
      e6_post.submission_file.update!(last_iqdb_checked_at: Time.current)
    end
  end
end
