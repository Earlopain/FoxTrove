module GitHelper
  def self.hash
    return @hash if instance_variable_defined? :@hash

    @hash = `git rev-parse --short HEAD`.strip
  end

  def self.url
    return @url if instance_variable_defined? :@url

    regex = %r{git@(\S*):(\S*)/(\S*)\.git|://(\S*)\.git}
    remote = `git config --get remote.origin.url`.strip
    match = remote.scan(regex).first
    @url = if match[0]
             "https://#{match[0]}/#{match[1]}/#{match[2]}"
           else
             "https://#{match[4]}"
           end
  end
end
