FactoryGirl.define do
  factory :current_role do
    slug {generate :text}
    name {generate :text}
  end
end

