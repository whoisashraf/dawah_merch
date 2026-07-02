admin_email = ENV.fetch("ADMIN_EMAIL", "admin@mssn.com")
admin_password = ENV.fetch("ADMIN_PASSWORD", "changeme123")

unless User.exists?(email_address: admin_email)
  User.create!(
    email_address: admin_email,
    password: admin_password,
    name: "Admin",
    admin: true
  )
  puts "Admin user created: #{admin_email} / #{admin_password}"
end
