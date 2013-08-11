require 'spec_helper'

describe User do
  describe  "#has_role?" do
    let(:user) {create :user}
    let(:role) {create :role}

    it "должно возвращать true если роль есть у пользователя" do
      user.roles << role
      user.has_role?(role.slug).should be_true
    end

    it "должно возвращать false если роли у пользователя нет" do
      user.has_role?(role.slug).should be_false
    end
  end

  describe "#add_role" do
    let(:user) {create :user}
    let(:role) {create :role}

    it "роль должна появляться у пользователя" do
      user.roles.should be_empty
      user.add_role role.slug
      user.roles.should include(role)
    end

    it "не должно быть ошибки при повторном добавлении роли" do
      user.add_role role.slug
      expect {user.add_role role.slug}.not_to raise_error
    end
  end

  describe "#remove_role" do
    let(:user) {create :user}
    let(:role) {create :role}

    it "должна исчезнуть у пользователя" do
      user.roles << role
      user.remove_role role.slug
      user.roles.should be_empty
    end

    it "не должно вызвать ошибки удаление отсутствующей роли" do
      expect {user.remove_role role.slug}.not_to raise_error
    end
  end
end

