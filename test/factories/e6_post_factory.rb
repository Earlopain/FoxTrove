FactoryBot.define do
  factory :e6_post do
    association :submission_file

    post_id { 123 }
    post_width { 100 }
    post_height { 100 }
    post_size { 300.kilobytes }
    similarity_score { 95 }
    is_exact_match { false }
    post_json { { "file" => { "url" => "https://localhost/image.png" }, "score" => { "total" => 50 } } }
    post_is_deleted { false }
  end
end
