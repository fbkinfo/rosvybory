FactoryGirl.define do
  factory :region do
    sequence(:name) { |n| "region#{n}" }
    kind :city

    trait :adm_region do
      kind :adm_region
      parent { FactoryGirl.create :region }
    end

    trait :mun_region do
      kind :mun_region
      parent { FactoryGirl.create :adm_region }
    end
  end
end
