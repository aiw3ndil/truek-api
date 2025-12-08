FactoryBot.define do
  factory :item do
    association :user
    title { Faker::Commerce.product_name }
    description { Faker::Lorem.paragraph }
    status { 'available' }

    trait :with_images do
      after(:create) do |item|
        create_list(:item_image, 3, item: item)
      end
    end

    trait :traded do
      status { 'traded' }
    end

    trait :unavailable do
      status { 'unavailable' }
    end
  end
end
