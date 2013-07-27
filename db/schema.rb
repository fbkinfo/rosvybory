# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20130726223510) do

  create_table "regions", force: true do |t|
    t.integer  "kind"
    t.integer  "parent_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "regions", ["parent_id"], name: "index_regions_on_parent_id", using: :btree

  create_table "user_apps", force: true do |t|
    t.string   "last_name"
    t.string   "first_name"
    t.string   "patronymic"
    t.string   "phone"
    t.string   "email"
    t.integer  "uic"
    t.integer  "current_status",    default: 0
    t.integer  "experience_count",  default: 0
    t.integer  "previous_statuses", default: 0
    t.boolean  "has_car"
    t.string   "social_accounts"
    t.text     "extra"
    t.integer  "legal_status"
    t.integer  "desired_statuses",  default: 0
    t.string   "app_code"
    t.integer  "app_status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "region_id"
  end

  add_index "user_apps", ["region_id"], name: "index_user_apps_on_region_id", using: :btree

end
