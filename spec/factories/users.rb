FactoryGirl.define do
  factory :user do
    email {generate :email}
    password 'password'
    phone { generate :phone}
  end
end
