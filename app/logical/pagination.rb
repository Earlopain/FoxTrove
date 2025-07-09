class Pagination
  DEFAULT_PER_PAGE = 25
  PAGINATION_WINDOW = 4

  def initialize(relation, limit:, page:)
    @relation = relation
    @limit = (limit || DEFAULT_PER_PAGE).to_i.clamp(1, nil)
    @page = (page || 1).to_i.clamp(1, nil)
    @offset = (@page - 1) * limit
  end

  def records
    @records ||= @relation.offset(@offset).limit(@limit)
  end

  def page_range
    last_page = (@relation.count / @limit).ceil
    if last_page < (PAGINATION_WINDOW * 2) + 1 + 2
      # 1 "2" 3 4 5 6
      1.upto(last_page).each { yield it }
    elsif @page - PAGINATION_WINDOW > 2 && @page + PAGINATION_WINDOW < last_page - 1
      # 1 ... 4 5 6 7 "8" 9 10 11 12 ... 15
      yield 1
      yield :gap

      (@page - PAGINATION_WINDOW).upto(@page - 1).each { yield it }
      yield @page.to_s
      (@page + 1).upto(@page + PAGINATION_WINDOW).each { yield it }

      yield :gap
      yield last_page
    elsif @page + Pagination::PAGINATION_WINDOW >= last_page
    else
    end
  end
end
