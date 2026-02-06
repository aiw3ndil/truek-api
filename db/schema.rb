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

ActiveRecord::Schema[7.1].define(version: 2026_02_04_111043) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "item_images", force: :cascade do |t|
    t.integer "item_id", null: false
    t.string "image_url", null: false
    t.integer "position", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id", "position"], name: "index_item_images_on_item_id_and_position"
    t.index ["item_id"], name: "index_item_images_on_item_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.integer "user_id", null: false
    t.string "status", default: "available", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_items_on_status"
    t.index ["user_id", "created_at"], name: "index_items_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_items_on_user_id"
  end

  create_table "trades", force: :cascade do |t|
    t.integer "proposer_id", null: false
    t.integer "proposer_item_id", null: false
    t.integer "receiver_id", null: false
    t.integer "receiver_item_id", null: false
    t.string "status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["proposer_id", "receiver_id"], name: "index_trades_on_proposer_id_and_receiver_id"
    t.index ["proposer_id"], name: "index_trades_on_proposer_id"
    t.index ["proposer_item_id"], name: "index_trades_on_proposer_item_id"
    t.index ["receiver_id"], name: "index_trades_on_receiver_id"
    t.index ["receiver_item_id"], name: "index_trades_on_receiver_item_id"
    t.index ["status"], name: "index_trades_on_status"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "name"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "google_id"
    t.string "provider", default: "email"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["google_id"], name: "index_users_on_google_id", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "item_images", "items"
  add_foreign_key "items", "users"
  add_foreign_key "trades", "items", column: "proposer_item_id"
  add_foreign_key "trades", "items", column: "receiver_item_id"
  add_foreign_key "trades", "users", column: "proposer_id"
  add_foreign_key "trades", "users", column: "receiver_id"
end
