FactoryBot.define do
  factory :notification do
    user { nil }
    title { "MyString" }
    message { "MyText" }
    link { "MyString" }
    notification_type { "MyString" }
    read { false }
  end
end
