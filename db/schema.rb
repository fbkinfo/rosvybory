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

ActiveRecord::Schema.define(version: 20130905183345) do

  create_table "active_admin_comments", force: true do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "blacklists", force: true do |t|
    t.string   "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "info"
  end

  add_index "blacklists", ["phone"], name: "index_blacklists_on_phone", unique: true, using: :btree

  create_table "call_center_phone_calls", force: true do |t|
    t.string   "status"
    t.string   "number"
    t.integer  "report_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.hstore   "all_params"
  end

  create_table "call_center_reporters", force: true do |t|
    t.integer  "user_id"
    t.integer  "uic_id"
    t.integer  "adm_region_id"
    t.integer  "mobile_group_id"
    t.string   "phone"
    t.string   "first_name"
    t.string   "patronymic"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "current_role_id"
  end

  create_table "call_center_reports", force: true do |t|
    t.text     "text"
    t.string   "url"
    t.integer  "reporter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "violation_id"
  end

  create_table "call_center_reports_relations", force: true do |t|
    t.integer  "parent_report_id"
    t.integer  "child_report_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "call_center_reports_relations", ["child_report_id"], name: "index_call_center_reports_relations_on_child_report_id", using: :btree
  add_index "call_center_reports_relations", ["parent_report_id"], name: "index_call_center_reports_relations_on_parent_report_id", using: :btree

  create_table "call_center_violation_categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "call_center_violation_types", force: true do |t|
    t.string   "name"
    t.integer  "violation_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "call_center_violations", force: true do |t|
    t.integer  "violation_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "current_roles", force: true do |t|
    t.string   "name",                   null: false
    t.string   "slug",                   null: false
    t.integer  "position",   default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mobile_groups", force: true do |t|
    t.integer  "organisation_id"
    t.string   "name"
    t.integer  "adm_region_id"
    t.integer  "region_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mobile_groups", ["organisation_id"], name: "index_mobile_groups_on_organisation_id", using: :btree

  create_table "nomination_sources", force: true do |t|
    t.string   "name"
    t.string   "variant"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organisations", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "regions", force: true do |t|
    t.integer  "kind"
    t.integer  "parent_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "has_tic",       default: false
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "adm_region_id"
  end

  add_index "regions", ["name"], name: "index_regions_on_name", unique: true, using: :btree
  add_index "regions", ["parent_id"], name: "index_regions_on_parent_id", using: :btree

  create_table "roles", force: true do |t|
    t.string   "name",       null: false
    t.string   "slug",       null: false
    t.string   "short_name", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name"], name: "index_roles_on_name", unique: true, using: :btree
  add_index "roles", ["short_name"], name: "index_roles_on_short_name", unique: true, using: :btree
  add_index "roles", ["slug"], name: "index_roles_on_slug", unique: true, using: :btree

  create_table "uics", force: true do |t|
    t.integer  "region_id",                          null: false
    t.integer  "number"
    t.boolean  "is_temporary",       default: false, null: false
    t.string   "has_koib",           default: "f",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "kind"
    t.string   "name"
    t.integer  "parent_id"
    t.integer  "participants_count"
  end

  add_index "uics", ["number"], name: "index_uics_on_number", unique: true, using: :btree
  add_index "uics", ["parent_id"], name: "index_uics_on_parent_id", using: :btree
  add_index "uics", ["region_id"], name: "index_uics_on_region_id", using: :btree

  create_table "user_app_current_roles", force: true do |t|
    t.integer  "user_app_id",     null: false
    t.integer  "current_role_id", null: false
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_app_current_roles", ["current_role_id"], name: "index_user_app_current_roles_on_current_role_id", using: :btree
  add_index "user_app_current_roles", ["user_app_id", "current_role_id"], name: "index_user_app_current_roles_on_user_app_id_and_current_role_id", unique: true, using: :btree

  create_table "user_apps", force: true do |t|
    t.string   "last_name"
    t.string   "first_name"
    t.string   "patronymic"
    t.string   "phone"
    t.string   "email"
    t.string   "uic"
    t.integer  "current_statuses",               default: 0
    t.integer  "experience_count",               default: 0
    t.integer  "previous_statuses",              default: 0
    t.boolean  "has_car"
    t.text     "social_accounts"
    t.text     "extra"
    t.integer  "legal_status"
    t.integer  "desired_statuses",               default: 0
    t.string   "app_code"
    t.integer  "app_status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "region_id"
    t.string   "ip"
    t.integer  "year_born"
    t.boolean  "sex_male"
    t.text     "useragent"
    t.integer  "adm_region_id"
    t.string   "state",                          default: "pending", null: false
    t.boolean  "phone_verified",                 default: false,     null: false
    t.boolean  "has_video"
    t.string   "forwarded_for"
    t.integer  "organisation_id"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.string   "full_name",          limit: 767
  end

  add_index "user_apps", ["adm_region_id"], name: "index_user_apps_on_adm_region_id", using: :btree
  add_index "user_apps", ["organisation_id"], name: "index_user_apps_on_organisation_id", using: :btree
  add_index "user_apps", ["region_id"], name: "index_user_apps_on_region_id", using: :btree

  create_table "user_current_roles", force: true do |t|
    t.integer  "user_id",                              null: false
    t.integer  "current_role_id",                      null: false
    t.integer  "uic_id"
    t.integer  "region_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "nomination_source_id"
    t.boolean  "got_docs",             default: false
  end

  add_index "user_current_roles", ["current_role_id"], name: "index_user_current_roles_on_current_role_id", using: :btree
  add_index "user_current_roles", ["region_id"], name: "index_user_current_roles_on_region_id", using: :btree
  add_index "user_current_roles", ["uic_id"], name: "index_user_current_roles_on_uic_id", using: :btree
  add_index "user_current_roles", ["user_id"], name: "index_user_current_roles_on_user_id", using: :btree

  create_table "user_roles", force: true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_roles", ["role_id"], name: "index_user_roles_on_role_id", using: :btree
  add_index "user_roles", ["user_id", "role_id"], name: "index_user_roles_on_user_id_and_role_id", unique: true, using: :btree
  add_index "user_roles", ["user_id"], name: "index_user_roles_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email"
    t.string   "encrypted_password",                 default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "region_id"
    t.integer  "organisation_id"
    t.string   "phone"
    t.integer  "adm_region_id"
    t.integer  "user_app_id"
    t.integer  "mobile_group_id"
    t.integer  "year_born"
    t.text     "place_of_birth"
    t.text     "passport"
    t.text     "work"
    t.text     "work_position"
    t.string   "last_name"
    t.string   "first_name"
    t.string   "patronymic"
    t.text     "address"
    t.string   "full_name",              limit: 767
  end

  add_index "users", ["adm_region_id"], name: "index_users_on_adm_region_id", using: :btree
  add_index "users", ["mobile_group_id"], name: "index_users_on_mobile_group_id", using: :btree
  add_index "users", ["organisation_id"], name: "index_users_on_organisation_id", using: :btree
  add_index "users", ["region_id"], name: "index_users_on_region_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "verifications", force: true do |t|
    t.string   "phone_number"
    t.string   "code"
    t.boolean  "confirmed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "work_logs", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.text     "params"
    t.string   "state",      default: "pending", null: false
    t.text     "results"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
