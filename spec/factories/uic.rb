FactoryGirl.define do
  factory :uic do
    region { FactoryGirl.create(:region) }
    number {generate :int}
  end
end

