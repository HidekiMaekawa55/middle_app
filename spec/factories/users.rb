FactoryBot.define do
  factory :user do
    name { "Test Tarou" }
    email { "test@example.com"} 
    password { "password" }
    password_confirmation { "password"}
    confirmed_at { Time.zone.now }
  end
end
