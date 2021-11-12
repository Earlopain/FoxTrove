class CurrentUser
  def self.user=(user)
    RequestStore[:current_user] = user
  end

  def self.user
    RequestStore[:current_user]
  end

  def self.ip_addr=(ip_addr)
    RequestStore[:current_ip_addr] = ip_addr
  end

  def self.ip_addr
    RequestStore[:current_ip_addr]
  end

  def self.method_missing(method, *params, &block)
    user.__send__(method, *params, &block)
  end
end
