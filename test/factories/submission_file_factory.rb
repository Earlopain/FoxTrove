FactoryBot.define do
  factory :submission_file do
    default_dummy_image = Vips::Image.black(1, 1).write_to_buffer(".png", bitdepth: 1)

    dummy_image = ->(evaluator) do
      buffer = if evaluator.width && evaluator.height
        Vips::Image.black(evaluator.width, evaluator.height).write_to_buffer(".png", bitdepth: 1)
      else
        default_dummy_image
      end
      StringIO.new(buffer)
    end

    association :artist_submission

    created_at_on_site { Time.current }
    direct_url { "https://localhost/image.webp" }
    sequence(:file_identifier) { |n| "file_identifier_#{n}" }

    transient do
      file_name { nil }
      with_sample { false }
    end

    before(:create) do |submission_file, evaluator|
      if evaluator.file_name && (evaluator.width || evaluator.height)
        raise "Can't have width/height with explicit file_name"
      end

      original = evaluator.file_name ? file_fixture(evaluator.file_name).open : dummy_image.call(evaluator)
      submission_file.attach_original_from_file!(original)
      submission_file.generate_variants if evaluator.with_sample
    end
  end
end
