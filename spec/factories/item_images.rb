FactoryBot.define do
  factory :item_image do
    association :item
    image_url { Faker::LoremFlickr.image(size: "300x300", search_terms: ['product']) }
    sequence(:position) { |n| n }
  end
end
