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

ActiveRecord::Schema[7.0].define(version: 2022_11_13_101044) do
  create_table "albums", primary_key: "albumid", id: { limit: 8 }, force: :cascade do |t|
    t.integer "singerid", limit: 8, null: false
    t.string "title", null: false
    t.time "created_at", null: false
    t.time "updated_at", null: false
  end

  create_table "customers", id: { limit: 8 }, force: :cascade do |t|
    t.string "name", null: false
    t.time "created_at", null: false
    t.time "updated_at", null: false
  end

  create_table "orders", id: { limit: 8 }, force: :cascade do |t|
    t.integer "customer_id", limit: 8, null: false
    t.integer "product_id", limit: 8, null: false
    t.integer "quantity", limit: 8, null: false
    t.time "created_at", null: false
    t.time "updated_at", null: false
  end

  create_table "products", id: { limit: 8 }, force: :cascade do |t|
    t.string "name", null: false
    t.float "price", null: false
    t.time "created_at", null: false
    t.time "updated_at", null: false
  end

  create_table "singers", primary_key: "singerid", id: { limit: 8 }, force: :cascade do |t|
    t.string "name", null: false
    t.time "created_at", null: false
    t.time "updated_at", null: false
  end

  create_table "songs", primary_key: "songid", id: { limit: 8 }, force: :cascade do |t|
    t.integer "singerid", limit: 8, null: false
    t.integer "albumid", limit: 8, null: false
    t.string "title", null: false
    t.time "created_at", null: false
    t.time "updated_at", null: false
  end

  add_foreign_key "orders", "customers"
  add_foreign_key "orders", "products"
end
