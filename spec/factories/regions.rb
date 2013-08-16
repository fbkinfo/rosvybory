FactoryGirl.define do
  factory :region do
    sequence(:name) { |n| "region#{n}" }
    kind Region::CITY

    trait :adm_region do
      kind Region::ADM_REGION
      parent { FactoryGirl.create :region }
    end

    trait :mun_region do
      kind Region::MUN_REGION
      parent { FactoryGirl.create :adm_region }
    end
  end
end
