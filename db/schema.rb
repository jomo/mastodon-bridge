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

ActiveRecord::Schema.define(version: 20170404222753) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authorizations", force: :cascade do |t|
    t.string   "provider"
    t.string   "uid"
    t.integer  "user_id"
    t.string   "token"
    t.string   "secret"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "profile_url",  default: "", null: false
    t.string   "display_name", default: "", null: false
    t.index ["provider", "uid"], name: "index_authorizations_on_provider_and_uid", unique: true, using: :btree
  end

  create_table "mastodon_clients", force: :cascade do |t|
    t.string   "domain"
    t.string   "client_id"
    t.string   "client_secret"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["domain"], name: "index_mastodon_clients_on_domain", unique: true, using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
