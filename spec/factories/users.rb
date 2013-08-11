FactoryGirl.define do
  factory :user do
    email {generate :email}
    password 'password'
  end
end
