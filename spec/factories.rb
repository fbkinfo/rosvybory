FactoryGirl.define do
  sequence(:email)        { |n| "person#{n}@example.com" }
  sequence(:phone)        { |n| "%010d" % n}
  sequence(:name)         { |n| "John #{n} Doe" }
  sequence(:text)         { |n| "Text #{n}" }
  sequence(:password)     { |n| "password" }
  sequence(:datetime)     { |n| Time.zone.now.ago(n.hours) }
  sequence(:date)         { |n| Time.zone.now.ago(n.days).to_date }
  sequence(:int)          { |n| n }
  sequence(:url)          { |n| "http://test.home/#{n}" }

  sequence(:mac) { |n|
    mac = n.to_s
    number_char_in_mac = 12
    number_addition_char = number_char_in_mac - mac.size
    mac + '0' * number_addition_char
  }
end
