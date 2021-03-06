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

ActiveRecord::Schema.define(version: 20160229125958) do

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
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "status"
    t.string   "contract_id"
    t.string   "customer_address"
    t.string   "customer_city"
    t.string   "customer_province"
    t.string   "customer_country"
    t.string   "customer_postal"
    t.string   "stripe_customer_id"
    t.integer  "price"
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
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "long_name"
    t.string   "processing_hours"
  end

  create_table "page_actions", force: :cascade do |t|
    t.integer  "page_view_id"
    t.string   "action"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "page_actions", ["page_view_id"], name: "index_page_actions_on_page_view_id", using: :btree

  create_table "page_views", force: :cascade do |t|
    t.integer  "viewer_id"
    t.string   "source"
    t.string   "page"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "page_views", ["viewer_id"], name: "index_page_views_on_viewer_id", using: :btree

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

  create_table "viewers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "bookings", "theatres"
  add_foreign_key "openings", "theatres"
  add_foreign_key "page_actions", "page_views"
  add_foreign_key "page_views", "viewers"
  add_foreign_key "prices", "theatres"
  add_foreign_key "theatres", "venues"
end
