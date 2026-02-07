FactoryBot.define do
  factory :trade do
    proposer { association :user }
    receiver { association :user }
    proposer_item { association :item, user: proposer }
    receiver_item { association :item, user: receiver }
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
