FactoryBot.define do
  factory :item_image do
    association :item
    after(:build) do |item_image|
      item_image.file.attach(
        io: File.open(Rails.root.join('spec/fixtures/files/image.jpg')),
        filename: 'image.jpg',
        content_type: 'image/jpeg'
      )
    end
    
    sequence(:position) { |n| n }
  end
end
