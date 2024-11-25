module GitHelper
  REPO = begin
    Rugged::Repository.new(Rails.root)
  rescue Rugged::RepositoryError, Rugged::ConfigError
    nil
  end

  COMMIT_ABREV_LENGTH = 7

  def self.enabled?
    REPO.present?
  end

  def self.last_commit_timestamp
    @last_commit_timestamp ||= REPO.last_commit.epoch_time
  end

  def self.last_commit_hash
    @last_commit_hash ||= REPO.last_commit.oid.first(COMMIT_ABREV_LENGTH)
  end

  def self.master_branch?
    @master_branch ||= REPO.head.name == "refs/heads/master"
  end

  def self.build_outdated?
    return false if !enabled? || DockerEnv.master_commit.blank? || !master_branch?

    @build_outdated ||= begin
      buildtime = REPO.lookup(DockerEnv.master_commit)
      current = REPO.lookup(last_commit_hash)
      changed_files = buildtime.diff(current).each_delta.map do |delta|
        [delta.old_file[:path], delta.new_file[:path]]
      end.flatten.uniq
      changed_files.intersect?(DockerEnv.docker_relevant_files)
    end
  end

  def self.url
    return @url if instance_variable_defined? :@url

    regex = %r{git@(\S*):(\S*)/(\S*)\.git|://(\S*)(\.git)?}
    remote = REPO.remotes.find { |r| r.name == "origin" }.url
    match = remote.scan(regex).first
    @url = if match[0]
      "https://#{match[0]}/#{match[1]}/#{match[2]}"
    else
      "https://#{match[4]}"
    end
  end
end
