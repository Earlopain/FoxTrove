Rails.application.config.after_initialize do |app|
  files_to_watch = [
    Config::DEFAULT_PATH,
    Config::CUSTOM_PATH,
    EsbuildManifest::FILE_PATH,
  ].map(&:to_s)

  dirs_to_watch = [
    Sites::DEFINITIONS_PATH,
  ].to_h { |dir| [dir.to_s, []] }

  reloader = app.config.file_watcher.new(files_to_watch, dirs_to_watch) do
    # Do nothing, just have changes to these files trigger a code reload
  end

  app.reloaders << reloader
  app.reloader.to_run { reloader.execute_if_updated }
end
