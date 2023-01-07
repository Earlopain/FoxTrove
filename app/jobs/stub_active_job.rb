# frozen_string_literal: true

module StubActiveJob
  def self.prepended(klass)
    klass.class_eval do
      def self.perform_later(blob)
        # Do nothing
      end
    end
  end

  def perform(blob)
    # Do nothing
  end
end
