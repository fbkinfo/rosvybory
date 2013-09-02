# encoding: utf-8

class AddMediaRepresentative < ActiveRecord::Migration
  def up
    CurrentRole.create! slug: 'journalist', name: "Представитель СМИ", position: 6
  end
end
