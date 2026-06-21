# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_21_150000) do
  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "stars", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "starred", default: false, null: false
    t.integer "technology_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["technology_id"], name: "index_stars_on_technology_id"
    t.index ["user_id"], name: "index_stars_on_user_id"
  end

  create_table "technologies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "github_url"
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["github_url"], name: "index_technologies_on_github_url"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "adminFlag"
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "sessions", "users"
  add_foreign_key "stars", "technologies"
  add_foreign_key "stars", "users"
end
