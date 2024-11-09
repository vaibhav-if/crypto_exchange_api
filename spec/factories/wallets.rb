FactoryBot.define do
  factory :wallet do
    user { nil }
    currency { "MyString" }
    balance { "9.99" }
  end
end
