FactoryGirl.define do
  factory :user do
    first_name        { Faker::NameRU.first_name }
    last_name         { Faker::NameRU.last_name }
    patronymic        { Faker::NameRU.patronymic }
    year_born         1967
    email {generate :email}
    password 'password'
    phone { generate :phone}
  end
end
