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

ActiveRecord::Schema[7.1].define(version: 2025_10_03_120000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "mensajes", force: :cascade do |t|
    t.bigint "reserva_id", null: false
    t.bigint "user_id", null: false
    t.text "contenido", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reserva_id"], name: "index_mensajes_on_reserva_id"
    t.index ["user_id"], name: "index_mensajes_on_user_id"
  end

  create_table "reservas", force: :cascade do |t|
    t.bigint "paciente_id", null: false
    t.bigint "doctor_id", null: false
    t.datetime "fecha_hora", null: false
    t.text "motivo", null: false
    t.text "notas"
    t.integer "estado", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["doctor_id"], name: "index_reservas_on_doctor_id"
    t.index ["paciente_id"], name: "index_reservas_on_paciente_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.string "firstname"
    t.string "lastname"
    t.string "phone"
    t.string "description"
    t.string "photo"
    t.integer "rol", default: 0
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "mensajes", "reservas"
  add_foreign_key "mensajes", "users"
  add_foreign_key "reservas", "users", column: "doctor_id"
  add_foreign_key "reservas", "users", column: "paciente_id"
end
