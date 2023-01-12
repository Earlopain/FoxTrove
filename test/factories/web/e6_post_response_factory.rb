# frozen_string_literal: true

FactoryBot.define do
  factory :e6_post_response, parent: :json do
    post_id { nil }
    md5 { nil }

    initialize_with do
      {
        post: {
          id: post_id,
          file: {
            width: 10,
            height: 10,
            size: 10.kilobytes,
            md5: md5,
          },
          flags: {
            deleted: false,
          },
        },
      }
    end
  end
end
