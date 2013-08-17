FactoryGirl.define do
  factory :user do
    email {generate :email}
    password 'password'
    phone {generate(:int).to_i}
  end
end
