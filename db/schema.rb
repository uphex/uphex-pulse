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

ActiveRecord::Schema.define(version: 13) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: true do |t|
    t.integer  "users_id"
    t.integer  "organizations_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", force: true do |t|
    t.date    "date"
    t.decimal "prediction_low"
    t.decimal "prediction_high"
    t.integer "metrics_id"
  end

  create_table "metrics", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "analyzed_at"
    t.integer  "providers_id"
    t.string   "last_error_type"
    t.datetime "last_error_time"
  end

  create_table "observations", force: true do |t|
    t.datetime "index"
    t.decimal  "value"
    t.string   "metadata"
    t.integer  "metrics_id"
  end

  create_table "organizations", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organizations", ["name"], name: "index_organizations_on_name", unique: true, using: :btree

  create_table "portfolios", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organizations_id"
  end

  add_index "portfolios", ["name"], name: "index_portfolios_on_name", unique: true, using: :btree

  create_table "providers", force: true do |t|
    t.string   "name"
    t.decimal  "userid"
    t.string   "access_token"
    t.string   "access_token_secret"
    t.datetime "expiration_date"
    t.string   "token_type"
    t.string   "refresh_token"
    t.text     "raw_response"
    t.integer  "portfolios_id"
    t.string   "provider_name"
    t.string   "profile_id"
  end

  create_table "users", force: true do |t|
    t.text     "name",          null: false
    t.text     "email",         null: false
    t.text     "password_hash", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["name"], name: "index_users_on_name", using: :btree

end
