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

ActiveRecord::Schema.define(version: 20150516170346) do

  create_table "activities", force: true do |t|
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "activities", ["user_id"], name: "index_activities_on_user_id"

  create_table "activity_relations", force: true do |t|
    t.integer "activity_id",         null: false
    t.integer "related_activity_id", null: false
    t.boolean "is_auto_generated",   null: false
    t.integer "owner_id",            null: false
  end

  add_index "activity_relations", ["activity_id", "related_activity_id"], name: "activity_relations_unique", unique: true
  add_index "activity_relations", ["owner_id"], name: "activity_relations_owner_id"

  create_table "activity_versions", force: true do |t|
    t.integer  "status"
    t.string   "name",               limit: 100
    t.datetime "published_at"
    t.string   "descr_material",     limit: 10000
    t.string   "descr_introduction", limit: 10000
    t.string   "descr_prepare",      limit: 10000
    t.string   "descr_main",         limit: 10000
    t.string   "descr_safety",       limit: 10000
    t.string   "descr_notes",        limit: 10000
    t.integer  "age_min"
    t.integer  "age_max"
    t.integer  "participants_min"
    t.integer  "participants_max"
    t.integer  "time_min"
    t.integer  "time_max"
    t.boolean  "featured"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "activity_id"
    t.integer  "user_id"
  end

  add_index "activity_versions", ["activity_id"], name: "index_activity_versions_on_activity_id"
  add_index "activity_versions", ["user_id"], name: "index_activity_versions_on_user_id"

  create_table "activity_versions_categories", id: false, force: true do |t|
    t.integer "category_id",         null: false
    t.integer "activity_version_id", null: false
  end

  add_index "activity_versions_categories", ["activity_version_id"], name: "index_activity_versions_categories_on_activity_version_id"
  add_index "activity_versions_categories", ["category_id"], name: "index_activity_versions_categories_on_category_id"

  create_table "activity_versions_media_files", id: false, force: true do |t|
    t.integer "activity_version_id", null: false
    t.integer "media_file_id",       null: false
    t.boolean "featured"
  end

  add_index "activity_versions_media_files", ["activity_version_id"], name: "index_activity_versions_media_files_on_activity_version_id"
  add_index "activity_versions_media_files", ["media_file_id"], name: "index_activity_versions_media_files_on_media_file_id"

  create_table "activity_versions_references", id: false, force: true do |t|
    t.integer "activity_version_id", null: false
    t.integer "reference_id",        null: false
  end

  add_index "activity_versions_references", ["activity_version_id"], name: "index_activity_versions_references_on_activity_version_id"
  add_index "activity_versions_references", ["reference_id"], name: "index_activity_versions_references_on_reference_id"

  create_table "categories", force: true do |t|
    t.string   "group"
    t.string   "name"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "media_file_id"
  end

  add_index "categories", ["group", "name"], name: "index_categories_on_group_and_name", unique: true
  add_index "categories", ["media_file_id"], name: "index_categories_on_media_file_id"
  add_index "categories", ["user_id"], name: "index_categories_on_user_id"

  create_table "comment_versions", force: true do |t|
    t.integer  "status"
    t.string   "text"
    t.string   "source_uri"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "comment_id"
  end

  add_index "comment_versions", ["comment_id"], name: "index_comment_versions_on_comment_id"

  create_table "comment_versions_media_files", id: false, force: true do |t|
    t.integer "comment_version_id", null: false
    t.integer "media_file_id",      null: false
  end

  add_index "comment_versions_media_files", ["comment_version_id"], name: "index_comment_versions_media_files_on_comment_version_id"
  add_index "comment_versions_media_files", ["media_file_id"], name: "index_comment_versions_media_files_on_media_file_id"

  create_table "comments", force: true do |t|
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "activity_id"
  end

  add_index "comments", ["activity_id"], name: "index_comments_on_activity_id"
  add_index "comments", ["user_id"], name: "index_comments_on_user_id"

  create_table "favourite_activities", id: false, force: true do |t|
    t.integer  "user_id",     null: false
    t.integer  "activity_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "favourite_activities", ["activity_id"], name: "index_favourite_activities_on_activity_id"
  add_index "favourite_activities", ["user_id"], name: "index_favourite_activities_on_user_id"

  create_table "media_files", force: true do |t|
    t.binary   "data"
    t.integer  "status"
    t.string   "mime_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uri"
  end

  add_index "media_files", ["uri"], name: "index_media_files_on_uri", unique: true

  create_table "ratings", id: false, force: true do |t|
    t.integer  "activity_id", null: false
    t.integer  "user_id",     null: false
    t.integer  "rating"
    t.text     "source_uri"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ratings", ["activity_id"], name: "index_ratings_on_activity_id"
  add_index "ratings", ["user_id"], name: "index_ratings_on_user_id"

  create_table "references", force: true do |t|
    t.string   "uri"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description"
  end

  create_table "system_messages", force: true do |t|
    t.string   "key",        limit: 100,   null: false
    t.string   "value",      limit: 10000, null: false
    t.datetime "validTo"
    t.datetime "validFrom"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "system_messages", ["key"], name: "index_system_messages_on_key"
  add_index "system_messages", ["user_id"], name: "index_system_messages_on_user_id"

  create_table "user_api_keys", force: true do |t|
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "user_api_keys", ["key"], name: "index_user_api_keys_on_key", unique: true
  add_index "user_api_keys", ["user_id"], name: "index_user_api_keys_on_user_id"

  create_table "user_identities", force: true do |t|
    t.string   "type"
    t.string   "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "user_identities", ["user_id"], name: "index_user_identities_on_user_id"

  create_table "users", force: true do |t|
    t.string   "email"
    t.boolean  "email_verified"
    t.string   "display_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "role",           default: 0, null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true

end
