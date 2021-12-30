module Cache
  module_function

  def fetch(key, expires_in = nil, &block)
    Rails.cache.fetch(key, expires_in: expires_in, &block)
  end

  def write(key, expires_in = nil)
    Rails.cache.write(key, value, expires_in: expires_in)
  end

  def clear
    Rails.cache.clear
  end
end
