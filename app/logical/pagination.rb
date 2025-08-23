class Pagination
  DEFAULT_PER_PAGE = 25

  attr_reader :current_page

  def initialize(relation, limit:, page:, pagination_window: 4)
    @pagination_window = pagination_window
    @relation = relation
    @limit = (limit || DEFAULT_PER_PAGE).to_i.clamp(1, nil)
    @current_page = (page || 1).to_i.clamp(1, last_page)
    @offset = (current_page - 1) * @limit
  end

  def last_page
    @last_page ||= (@relation.count / @limit.to_f).ceil.clamp(1, nil)
  end

  def records
    @records ||= @relation.offset(@offset).limit(@limit)
  end

  def pages
    return to_enum(__method__) unless block_given?

    left_window = current_page > @pagination_window + 3
    if left_window
      yield 1
      yield :gap
      (current_page - @pagination_window).upto(current_page - 1).each { yield it }
    else
      1.upto(current_page - 1).each { yield it }
    end

    yield current_page

    right_window = current_page < last_page - @pagination_window - 2
    if right_window
      (current_page + 1).upto(current_page + @pagination_window).each { yield it }
      yield :gap
      yield last_page
    else
      (current_page + 1).upto(last_page).each { yield it }
    end
  end
end
