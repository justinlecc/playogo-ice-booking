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

ActiveRecord::Schema.define(version: 20160130205826) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bookings", force: :cascade do |t|
    t.string   "date"
    t.integer  "start_time"
    t.integer  "length"
    t.string   "name"
    t.string   "phone"
    t.string   "email"
    t.string   "notes"
    t.string   "activity_type"
    t.integer  "theatre_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "status"
    t.string   "contract_id"
    t.string   "customer_address"
    t.string   "customer_city"
    t.string   "customer_province"
    t.string   "customer_country"
    t.string   "customer_postal"
  end

  add_index "bookings", ["theatre_id"], name: "index_bookings_on_theatre_id", using: :btree

  create_table "openings", force: :cascade do |t|
    t.integer  "start_time"
    t.integer  "length"
    t.string   "date"
    t.integer  "theatre_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "openings", ["theatre_id"], name: "index_openings_on_theatre_id", using: :btree

  create_table "owners", force: :cascade do |t|
    t.string   "name"
    t.string   "manager_name"
    t.string   "manager_email"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "long_name"
  end

  create_table "prices", force: :cascade do |t|
    t.integer  "prime"
    t.integer  "non_prime"
    t.integer  "insurance"
    t.integer  "theatre_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "prices", ["theatre_id"], name: "index_prices_on_theatre_id", using: :btree

  create_table "stripe_accounts", force: :cascade do |t|
    t.string   "account_name"
    t.string   "live_public_token"
    t.string   "live_private_token"
    t.string   "test_public_token"
    t.string   "test_private_token"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "theatres", force: :cascade do |t|
    t.string   "name"
    t.integer  "venue_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "theatres", ["venue_id"], name: "index_theatres_on_venue_id", using: :btree

  create_table "venues", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "owner_id"
    t.float    "lat"
    t.float    "long"
    t.string   "address"
  end

  add_foreign_key "bookings", "theatres"
  add_foreign_key "openings", "theatres"
  add_foreign_key "prices", "theatres"
  add_foreign_key "theatres", "venues"
end
