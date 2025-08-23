require "test_helper"

class PaginationTest < ActiveSupport::TestCase
  def new_paginator(**)
    Pagination.new(Artist, **)
  end

  describe "records" do
    it "works when there are no matches" do
      assert_empty(new_paginator(limit: 1, page: 1).records)
      assert_empty(new_paginator(limit: 2, page: 1).records)
      assert_empty(new_paginator(limit: 1, page: 2).records)
    end

    it "returns partial results when the last page can't be filled" do
      r = create_list(:artist, 10)
      assert_equal([r[0], r[1], r[2]], new_paginator(limit: 3, page: 1).records)
      assert_equal([r[3], r[4], r[5]], new_paginator(limit: 3, page: 2).records)
      assert_equal([r[6], r[7], r[8]], new_paginator(limit: 3, page: 3).records)
      assert_equal([r[9]], new_paginator(limit: 3, page: 4).records)
    end
  end

  describe "#page_range" do
    def assert_pages(element_count, expected, page:)
      # Allow marking the current page by passing it in as a string.
      # The reason being that it makes the tests easier to read.
      expected.map! { it.is_a?(String) ? it.to_i : it }
      actual = []
      Artist.transaction do
        create_list(:artist, element_count)
        paginator = new_paginator(limit: 1, page: page, pagination_window: 2)
        actual = paginator.pages.to_a
        raise ActiveRecord::Rollback
      end
      assert_equal(expected, actual)
    end

    it "handles pagination starting from page 1" do
      with_options(page: 1) do
        assert_pages(1, ["1"])
        assert_pages(2, ["1", 2])
        assert_pages(3, ["1", 2, 3])
        assert_pages(4, ["1", 2, 3, 4])
        assert_pages(5, ["1", 2, 3, 4, 5])
        assert_pages(6, ["1", 2, 3, :gap, 6])
        assert_pages(7, ["1", 2, 3, :gap, 7])
      end
    end

    it "handles pagination starting from page 6" do
      with_options(page: 6) do
        assert_pages(1, ["1"])
        assert_pages(2, [1, "2"])
        assert_pages(3, [1, 2, "3"])
        assert_pages(4, [1, 2, 3, "4"])
        assert_pages(5, [1, 2, 3, 4, "5"])
        assert_pages(6, [1, :gap, 4, 5, "6"])
        assert_pages(7, [1, :gap, 4, 5, "6", 7])
        assert_pages(8, [1, :gap, 4, 5, "6", 7, 8])
        assert_pages(9, [1, :gap, 4, 5, "6", 7, 8, 9])
        assert_pages(10, [1, :gap, 4, 5, "6", 7, 8, 9, 10])
        assert_pages(11, [1, :gap, 4, 5, "6", 7, 8, :gap, 11])
        assert_pages(12, [1, :gap, 4, 5, "6", 7, 8, :gap, 12])
      end
    end

    it "handles pagination starting from the last page" do
      with_options(page: 7) do
        assert_pages(1, ["1"])
        assert_pages(2, [1, "2"])
        assert_pages(3, [1, 2, "3"])
        assert_pages(4, [1, 2, 3, "4"])
        assert_pages(5, [1, 2, 3, 4, "5"])
        assert_pages(6, [1, :gap, 4, 5, "6"])
        assert_pages(7, [1, :gap, 5, 6, "7"])
      end
    end

    it "handles lower/higher pages than available" do
      assert_pages(3, ["1", 2, 3], page: 0)
      assert_pages(3, [1, 2, "3"], page: 4)
    end
  end
end
