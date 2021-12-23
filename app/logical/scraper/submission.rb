module Scraper
  class Submission
    attr_accessor :identifier, :created_at, :title, :description, :files

    def initialize
      @files = []
    end
  end
end
