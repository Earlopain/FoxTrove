Rails.application.config.after_initialize do
  Listen.to(Rails.root.join("config"), only: /foxtrove.*\.yml/) do
    Config.reset_cache
  end.start

  Listen.to(Rails.root.join("app/logical/sites/definitions"), only: /.*\.yml/) do
    Sites.reset_cache
  end.start

  Listen.to(EsbuildManifest::FILE_LOCATION.dirname, only: /#{EsbuildManifest::FILE_LOCATION.basename}$/) do
    EsbuildManifest.reset_cache
  end.start
end
