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

unless Product.exists?(name: "Doxaclasm Hoodie")
  Product.create!(
    name: "Doxaclasm Hoodie",
    base_price: 600000,
    has_sizes: true,
    has_custom_name: true,
    custom_name_fee: 100000,
    active: true,
    options: [
      { "name" => "Size", "values" => ["XXL", "XL", "L", "M", "S"] },
      { "name" => "Color", "values" => ["Pitch Black", "Vintage White"] }
    ]
  )
  puts "Seed Product 'Doxaclasm Hoodie' created"
end

unless Product.exists?(name: "Doxaclasm Cap")
  Product.create!(
    name: "Doxaclasm Cap",
    base_price: 350000,
    has_sizes: false,
    has_custom_name: false,
    active: true,
    options: [
      { "name" => "Color", "values" => ["Pitch Black", "Teal Green"] }
    ]
  )
  puts "Seed Product 'Doxaclasm Cap' created"
end
