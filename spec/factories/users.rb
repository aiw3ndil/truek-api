FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { 'password123' }
    password_confirmation { 'password123' }
    provider { 'email' }

    trait :google_user do
      google_id { SecureRandom.uuid }
      picture { Faker::Avatar.image }
      provider { 'google' }
      password_digest { nil }
    end
  end
end
