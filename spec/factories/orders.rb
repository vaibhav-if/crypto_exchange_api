FactoryBot.define do
  factory :order do
    user { nil }
    side { "MyString" }
    base_currency { "MyString" }
    quote_currency { "MyString" }
    price { "9.99" }
    volume { "9.99" }
    state { "MyString" }
  end
end
