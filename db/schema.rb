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

ActiveRecord::Schema[7.2].define(version: 2026_05_02_092001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "gym_schedules", force: :cascade do |t|
    t.bigint "gym_id", null: false
    t.integer "day_of_week"
    t.time "start_time"
    t.time "end_time"
    t.integer "price"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["gym_id"], name: "index_gym_schedules_on_gym_id"
  end

  create_table "gyms", force: :cascade do |t|
    t.string "name", null: false
    t.string "address"
    t.string "ward"
    t.string "nearest_station"
    t.string "phone"
    t.string "website"
    t.string "reservation_url"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "postal_code"
  end

  add_foreign_key "gym_schedules", "gyms"
end
