User.find_or_create_by!(name: "admin") do |user|
  user.password = "test123"
  user.email = "admin@localhost"
  user.level = User::Levels::ADMIN
  user.last_logged_in_at = Time.now
  user.last_ip_addr = "127.0.0.1"
  user.created_at = Time.now
  user.updated_at = Time.now
end
