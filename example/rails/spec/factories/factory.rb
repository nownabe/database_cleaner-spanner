FactoryBot.define do
  factory :customer do
    name { "customer" }
  end

  factory :product do
    name { "product" }
    price { 1.0 }
  end

  factory :order do
    customer
    product
    quantity { 1 }
  end

  factory :singer do
    name { "singer" }
  end

  factory :album do
    singer
    albumid { 1 }
    title { "album" }
  end

  factory :song do
    singer
    album
    songid { 1 }
    title { "song" }
  end
end
