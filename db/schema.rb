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

ActiveRecord::Schema.define(version: 20150821005315) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admins", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree

  create_table "libraries", force: :cascade do |t|
    t.string  "name"
    t.string  "tag_new",    default: "new"
    t.boolean "tag_aspect", default: true
    t.boolean "tag_date",   default: true
    t.boolean "tag_camera", default: false
  end

  create_table "library_memberships", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "library_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "selection"
  end

  create_table "tags", force: :cascade do |t|
    t.integer  "upload_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["upload_id", "name"], name: "index_tags_on_upload_id_and_name", unique: true, using: :btree

  create_table "upload_buffers", force: :cascade do |t|
    t.integer "user_id"
    t.string  "key"
    t.string  "data"
  end

  add_index "upload_buffers", ["key"], name: "index_upload_buffers_on_key", unique: true, using: :btree

  create_table "uploads", force: :cascade do |t|
    t.string   "type"
    t.integer  "uploader_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file"
    t.datetime "modified_at"
    t.string   "name"
    t.integer  "size"
    t.string   "mime"
    t.text     "description"
    t.integer  "library_id"
    t.string   "state"
    t.datetime "imported_at"
    t.integer  "width"
    t.integer  "height"
    t.text     "metadata"
    t.datetime "deleted_at"
    t.datetime "taken_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.integer  "failed_attempts",        default: 0,     null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "name"
    t.boolean  "manual_deselect",        default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

end
