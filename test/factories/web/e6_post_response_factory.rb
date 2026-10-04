FactoryBot.define do
  factory :e6_post_response, parent: :json do
    post_id { nil }
    md5 { nil }

    json do
      {
        id: post_id,
        files: {
          meta: {
            size: 10.kilobytes,
            md5: md5,
          },
          original: {
            width: 10,
            height: 10,
          },
          sample: {
            jpg: "https://static1.e621.net/data/#{md5[0..1]}/#{md5[2..3]}/#{md5}.png",
          },
        },
        flags: {
          deleted: false,
        },
      }
    end
  end
end
