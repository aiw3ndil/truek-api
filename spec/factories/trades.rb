FactoryBot.define do
  factory :trade do
    association :proposer, factory: :user
    association :receiver, factory: :user
    association :proposer_item, factory: :item
    association :receiver_item, factory: :item
    status { 'pending' }

    trait :accepted do
      status { 'accepted' }
    end

    trait :rejected do
      status { 'rejected' }
    end

    trait :cancelled do
      status { 'cancelled' }
    end

    trait :completed do
      status { 'completed' }
    end
  end
end
