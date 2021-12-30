module GitHelper
  def self.git_hash
    return @git_hash if instance_variable_defined? :@git_hash

    @git_hash = `git rev-parse --short HEAD`.strip if system("git rev-parse --show-toplevel", %i[out err] => File::NULL)
  end
end
