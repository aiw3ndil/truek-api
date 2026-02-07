FactoryBot.define do
  factory :message do
    content { "MyText" }
    trade { nil }
    user { nil }
  end
end
