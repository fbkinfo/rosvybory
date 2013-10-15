FactoryGirl.define do
  factory :user do
    first_name        { Faker::NameRU.first_name }
    last_name         { Faker::NameRU.last_name }
    patronymic        { Faker::NameRU.patronymic }
    year_born         1967
    email {generate :email}
    password 'password'
    phone { generate :phone}
    wrong_phone false

    factory :user_with_role do
      ignore do
        role_slug 'other'
      end
      after(:create) do |user, evaluator|
        user.add_role evaluator.role_slug
        user.save!
      end
    end


  end
end
