FactoryGirl.define do
  factory :role do
    slug {generate :text}
    name {generate :text}
    short_name {generate :text}
  end
end

