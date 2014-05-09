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

ActiveRecord::Schema.define(version: 3) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "organization_memberships", id: false, force: true do |t|
    t.integer  "organization_id", null: false
    t.integer  "user_id",         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organization_memberships", ["organization_id", "user_id"], name: "index_organization_memberships_on_organization_id_and_user_id", unique: true, using: :btree
  add_index "organization_memberships", ["organization_id"], name: "index_organization_memberships_on_organization_id", using: :btree
  add_index "organization_memberships", ["user_id"], name: "index_organization_memberships_on_user_id", using: :btree

  create_table "organizations", force: true do |t|
    t.text     "name",       null: false
    t.text     "slug",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organizations", ["name"], name: "index_organizations_on_name", using: :btree
  add_index "organizations", ["slug"], name: "index_organizations_on_slug", unique: true, using: :btree

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
