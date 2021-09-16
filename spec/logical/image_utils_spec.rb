require "rails_helper"

RSpec.describe ImageUtils do
  context "thumbnails" do
    where(:input_file, :expected_width, :expected_height) do
      [
        ["1.jpg", 200, 133],
        ["1.png", 113, 200],
        ["1.gif", 200, 125],
        ["1.webp", 200, 150],
      ]
    end

    with_them do
      it "should generate the thumbnail" do
        image = Vips::Image.new_from_file ImageUtils.thumbnail(file_fixture(input_file).open).path
        width, height = image.size
        expect(width).to be expected_width
        expect(height).to be expected_height
      end
    end
  end
end
