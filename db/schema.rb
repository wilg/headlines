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

ActiveRecord::Schema.define(version: 20131230061035) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "comments", force: true do |t|
    t.integer  "headline_id"
    t.integer  "user_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "headlines", force: true do |t|
    t.string   "name"
    t.integer  "vote_count",     default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "source_names"
    t.string   "name_hash"
    t.integer  "depth",          default: 2
    t.integer  "creator_id"
    t.integer  "comments_count", default: 0, null: false
  end

  create_table "source_headline_fragments", force: true do |t|
    t.integer  "source_headline_id"
    t.integer  "headline_id"
    t.integer  "source_headline_start"
    t.integer  "source_headline_end"
    t.integer  "index"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "source_headline_fragments", ["headline_id"], name: "index_source_headline_fragments_on_headline_id", using: :btree
  add_index "source_headline_fragments", ["source_headline_id"], name: "index_source_headline_fragments_on_source_headline_id", using: :btree

  create_table "source_headlines", force: true do |t|
    t.string   "source_id"
    t.string   "name"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "source_headlines", ["source_id"], name: "index_source_headlines_on_source_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "login",               default: "", null: false
    t.string   "encrypted_password",  default: "", null: false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",       default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "vote_count",          default: 0,  null: false
    t.integer  "karma",               default: 0,  null: false
    t.integer  "comments_count",      default: 0,  null: false
  end

  add_index "users", ["login"], name: "index_users_on_login", unique: true, using: :btree

  create_table "votes", force: true do |t|
    t.integer  "value"
    t.integer  "headline_id"
    t.integer  "user_id"
    t.string   "ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
