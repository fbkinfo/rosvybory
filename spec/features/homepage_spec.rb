require 'spec_helper'

describe 'Home page' do
  it 'should have title' do
    visit '/'
    within '.page-header' do
      expect(page).to have_content 'Регистрация'
    end
  end
end
