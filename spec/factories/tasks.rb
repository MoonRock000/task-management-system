FactoryBot.define do
  factory :task do
    title { Faker::Lorem.word }
  end
end