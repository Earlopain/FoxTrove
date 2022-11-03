# frozen_string_literal: true

Rails.application.config.after_initialize do
  Listen.to(Rails.root.join("config"), only: /reverser.*\.yml/) do
    Config.force_reload
  end.start

  Listen.to(Rails.root.join("app/logical/sites/definitions"), only: /.*\.yml/) do
    Sites.reset_cache
  end.start
end
