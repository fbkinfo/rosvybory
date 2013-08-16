FactoryGirl.define do
  factory :verification do
    phone_number '0668250000'

    trait :confirmed do
      confirmed true
    end
  end
end
