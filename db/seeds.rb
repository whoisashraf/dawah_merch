admin_email = ENV.fetch("ADMIN_EMAIL")
admin_password = ENV.fetch("ADMIN_PASSWORD")

unless User.exists?(email_address: admin_email)
  User.create!(
    email_address: admin_email,
    password: admin_password,
    name: "Admin",
    admin: true
  )
  puts "Admin user created: #{admin_email}"
end
