# frozen_string_literal: true

module Archives
  ALL = [
    Archives::Tumblr,
  ].freeze

  def self.detect(file)
    archive_class = ALL.find { |clazz| clazz.handles_file(file) }
    archive_class.new(file)
  end
end
