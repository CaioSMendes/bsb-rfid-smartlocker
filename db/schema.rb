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

ActiveRecord::Schema[7.0].define(version: 2025_09_22_212326) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  create_table "asset_managements", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "serial"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_asset_managements_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.bigint "asset_management_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["asset_management_id"], name: "index_categories_on_asset_management_id"
    t.index ["user_id"], name: "index_categories_on_user_id"
  end

  create_table "deliverers", force: :cascade do |t|
    t.string "name"
    t.string "serial"
    t.string "lastname"
    t.string "phone"
    t.string "email"
    t.string "cpf"
    t.string "pin"
    t.bigint "keylocker_id"
    t.boolean "enabled"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "deliveries", force: :cascade do |t|
    t.string "package_description"
    t.bigint "deliverer_id"
    t.bigint "employee_id"
    t.datetime "delivery_date"
    t.string "locker_code"
    t.string "full_address"
    t.string "imageEntregador"
    t.string "imageInvoice"
    t.string "imageProduct"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "email_settings", force: :cascade do |t|
    t.string "address"
    t.integer "port"
    t.string "user_name"
    t.string "password"
    t.string "authentication"
    t.boolean "enable_starttls_auto"
    t.boolean "tls"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "employees", force: :cascade do |t|
    t.string "name"
    t.string "lastname"
    t.string "companyID"
    t.string "phone"
    t.string "email"
    t.string "function"
    t.string "PIN"
    t.string "cpf"
    t.string "pswdSmartlocker"
    t.string "cardRFID"
    t.string "status"
    t.string "matricula"
    t.boolean "operator", default: true, null: false
    t.boolean "delivery", default: true, null: false
    t.boolean "enabled", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "profile_picture"
    t.index ["user_id"], name: "index_employees_on_user_id"
  end

  create_table "employees_keylockers", force: :cascade do |t|
    t.bigint "employee_id", null: false
    t.bigint "keylocker_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_employees_keylockers_on_employee_id"
    t.index ["keylocker_id"], name: "index_employees_keylockers_on_keylocker_id"
  end

  create_table "historic_managements", force: :cascade do |t|
    t.bigint "item_id", null: false
    t.bigint "user_id", null: false
    t.string "action"
    t.text "description"
    t.datetime "action_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_historic_managements_on_item_id"
    t.index ["user_id"], name: "index_historic_managements_on_user_id"
  end

  create_table "history_entries", force: :cascade do |t|
    t.string "owner"
    t.string "name_device"
    t.json "employee_info"
    t.json "keys_taken", default: []
    t.json "keys_returned", default: []
    t.json "sequence_order", default: []
    t.string "datahistory"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "items", force: :cascade do |t|
    t.bigint "asset_management_id", null: false
    t.bigint "category_id", null: false
    t.bigint "location_id", null: false
    t.string "name"
    t.string "tagRFID"
    t.string "idInterno"
    t.string "description"
    t.string "image"
    t.string "status"
    t.integer "empty", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["asset_management_id"], name: "index_items_on_asset_management_id"
    t.index ["category_id"], name: "index_items_on_category_id"
    t.index ["location_id"], name: "index_items_on_location_id"
  end

  create_table "key_usages", force: :cascade do |t|
    t.bigint "employee_id", null: false
    t.bigint "keylocker_id", null: false
    t.string "keys"
    t.string "status"
    t.datetime "action_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_key_usages_on_employee_id"
    t.index ["keylocker_id"], name: "index_key_usages_on_keylocker_id"
  end

  create_table "keylocker_transactions", force: :cascade do |t|
    t.bigint "keylocker_info_id", null: false
    t.bigint "giver_employee_id", null: false
    t.bigint "receiver_employee_id", null: false
    t.bigint "keylocker_id"
    t.string "status", default: "disponível", null: false
    t.datetime "delivered_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "empty_at_moment"
    t.string "movement_description"
    t.index ["giver_employee_id"], name: "index_keylocker_transactions_on_giver_employee_id"
    t.index ["keylocker_id"], name: "index_keylocker_transactions_on_keylocker_id"
    t.index ["keylocker_info_id"], name: "index_keylocker_transactions_on_keylocker_info_id"
    t.index ["receiver_employee_id"], name: "index_keylocker_transactions_on_receiver_employee_id"
  end

  create_table "keylockerinfos", force: :cascade do |t|
    t.string "object"
    t.integer "posicion"
    t.string "tagRFID"
    t.string "idInterno"
    t.string "description"
    t.string "image"
    t.integer "empty", default: 1, null: false
    t.bigint "keylocker_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["keylocker_id"], name: "index_keylockerinfos_on_keylocker_id"
  end

  create_table "keylockers", force: :cascade do |t|
    t.string "owner"
    t.string "nameDevice"
    t.string "cnpjCpf"
    t.integer "qtd"
    t.integer "qtdDigito"
    t.string "serial"
    t.string "status"
    t.string "lockertype"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "door", default: "fechado"
  end

  create_table "keylogs", force: :cascade do |t|
    t.integer "position"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.string "address"
    t.text "description"
    t.bigint "asset_management_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["asset_management_id"], name: "index_locations_on_asset_management_id"
    t.index ["user_id"], name: "index_locations_on_user_id"
  end

  create_table "logs", force: :cascade do |t|
    t.bigint "employee_id", null: false
    t.string "action"
    t.string "key_id"
    t.string "locker_name"
    t.string "locker_serial"
    t.string "locker_object"
    t.datetime "timestamp"
    t.string "status"
    t.text "comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "keylocker_id"
    t.index ["employee_id"], name: "index_logs_on_employee_id"
  end

  create_table "logsmovimetations", force: :cascade do |t|
    t.bigint "employee_id", null: false
    t.string "action"
    t.string "tagrfid"
    t.string "key_id"
    t.string "locker_name"
    t.string "locker_serial"
    t.string "locker_object"
    t.datetime "timestamp"
    t.string "status"
    t.text "comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "keylocker_id", null: false
    t.index ["employee_id"], name: "index_logsmovimetations_on_employee_id"
    t.index ["keylocker_id"], name: "index_logsmovimetations_on_keylocker_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "package_description"
    t.string "locker_code"
    t.string "pin"
    t.string "full_address"
    t.string "imageEntregador"
    t.string "imageInvoice"
    t.string "imageProduct"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "serial"
  end

  create_table "sendsms", force: :cascade do |t|
    t.string "user"
    t.string "password"
    t.text "msg"
    t.string "url"
    t.string "hashSeguranca"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_lockers", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "keylocker_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["keylocker_id"], name: "index_user_lockers_on_keylocker_id"
    t.index ["user_id"], name: "index_user_lockers_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role"
    t.string "authentication_token"
    t.string "phone"
    t.string "name"
    t.string "lastname"
    t.string "cnpj"
    t.string "nameCompany"
    t.boolean "assetManagement", default: false
    t.boolean "lockerControl", default: false
    t.string "street"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.string "neighborhood"
    t.string "finance"
    t.string "complement"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "workdays", force: :cascade do |t|
    t.time "start", null: false
    t.time "end", null: false
    t.boolean "monday", default: false
    t.boolean "tuesday", default: false
    t.boolean "wednesday", default: false
    t.boolean "thursday", default: false
    t.boolean "friday", default: false
    t.boolean "saturday", default: false
    t.boolean "sunday", default: false
    t.boolean "enabled", default: true, null: false
    t.bigint "employee_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_workdays_on_employee_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "asset_managements", "users"
  add_foreign_key "categories", "asset_managements"
  add_foreign_key "categories", "users"
  add_foreign_key "employees", "users"
  add_foreign_key "employees_keylockers", "employees"
  add_foreign_key "employees_keylockers", "keylockers"
  add_foreign_key "historic_managements", "items"
  add_foreign_key "historic_managements", "users"
  add_foreign_key "items", "asset_managements"
  add_foreign_key "items", "categories"
  add_foreign_key "items", "locations"
  add_foreign_key "key_usages", "employees"
  add_foreign_key "key_usages", "keylockers"
  add_foreign_key "keylockerinfos", "keylockers"
  add_foreign_key "locations", "asset_managements"
  add_foreign_key "locations", "users"
  add_foreign_key "logs", "employees"
  add_foreign_key "logsmovimetations", "employees"
  add_foreign_key "logsmovimetations", "keylockers"
  add_foreign_key "user_lockers", "keylockers"
  add_foreign_key "user_lockers", "users"
  add_foreign_key "workdays", "employees"
end
