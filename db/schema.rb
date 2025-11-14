# frozen_string_literal: true

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

ActiveRecord::Schema[7.1].define(version: 20_251_023_025_019) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'active_storage_attachments', force: :cascade do |t|
    t.string 'name', null: false
    t.string 'record_type', null: false
    t.bigint 'record_id', null: false
    t.bigint 'blob_id', null: false
    t.datetime 'created_at', null: false
    t.index ['blob_id'], name: 'index_active_storage_attachments_on_blob_id'
    t.index %w[record_type record_id name blob_id], name: 'index_active_storage_attachments_uniqueness',
                                                    unique: true
  end

  create_table 'active_storage_blobs', force: :cascade do |t|
    t.string 'key', null: false
    t.string 'filename', null: false
    t.string 'content_type'
    t.text 'metadata'
    t.string 'service_name', null: false
    t.bigint 'byte_size', null: false
    t.string 'checksum'
    t.datetime 'created_at', null: false
    t.index ['key'], name: 'index_active_storage_blobs_on_key', unique: true
  end

  create_table 'active_storage_variant_records', force: :cascade do |t|
    t.bigint 'blob_id', null: false
    t.string 'variation_digest', null: false
    t.index %w[blob_id variation_digest], name: 'index_active_storage_variant_records_uniqueness', unique: true
  end

  create_table 'horario_atencions', force: :cascade do |t|
    t.bigint 'doctor_id', null: false
    t.time 'hora_inicio', null: false
    t.time 'hora_fin', null: false
    t.boolean 'disponible', default: true
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'ubicacion'
    t.date 'fecha', null: false
    t.index %w[doctor_id fecha hora_inicio],
            name: 'index_horario_atencions_on_doctor_id_and_fecha_and_hora_inicio', unique: true
    t.index ['doctor_id'], name: 'index_horario_atencions_on_doctor_id'
  end

  create_table 'mensajes', force: :cascade do |t|
    t.bigint 'reserva_id', null: false
    t.bigint 'user_id', null: false
    t.text 'contenido', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['reserva_id'], name: 'index_mensajes_on_reserva_id'
    t.index ['user_id'], name: 'index_mensajes_on_user_id'
  end

  create_table 'resenas', force: :cascade do |t|
    t.bigint 'reserva_id', null: false
    t.bigint 'autor_id', null: false
    t.integer 'rating', null: false
    t.text 'comment'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['autor_id'], name: 'index_resenas_on_autor_id'
    t.index %w[reserva_id autor_id], name: 'index_resenas_on_reserva_id_and_autor_id', unique: true
    t.index ['reserva_id'], name: 'index_resenas_on_reserva_id'
  end

  create_table 'reservas', force: :cascade do |t|
    t.bigint 'paciente_id', null: false
    t.bigint 'doctor_id', null: false
    t.datetime 'fecha_hora', null: false
    t.text 'motivo', null: false
    t.text 'notas'
    t.integer 'estado', default: 0
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.integer 'duracion', null: false
    t.string 'ubicacion', null: false
    t.index ['doctor_id'], name: 'index_reservas_on_doctor_id'
    t.index ['paciente_id'], name: 'index_reservas_on_paciente_id'
  end

  create_table 'users', force: :cascade do |t|
    t.string 'email', default: '', null: false
    t.string 'encrypted_password', default: '', null: false
    t.string 'reset_password_token'
    t.datetime 'reset_password_sent_at'
    t.datetime 'remember_created_at'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'username'
    t.string 'firstname'
    t.string 'lastname'
    t.string 'phone'
    t.string 'description'
    t.integer 'rol', default: 0
    t.index ['email'], name: 'index_users_on_email', unique: true
    t.index ['reset_password_token'], name: 'index_users_on_reset_password_token', unique: true
  end

  add_foreign_key 'active_storage_attachments', 'active_storage_blobs', column: 'blob_id'
  add_foreign_key 'active_storage_variant_records', 'active_storage_blobs', column: 'blob_id'
  add_foreign_key 'horario_atencions', 'users', column: 'doctor_id'
  add_foreign_key 'mensajes', 'reservas'
  add_foreign_key 'mensajes', 'users'
  add_foreign_key 'resenas', 'reservas'
  add_foreign_key 'resenas', 'users', column: 'autor_id'
  add_foreign_key 'reservas', 'users', column: 'doctor_id'
  add_foreign_key 'reservas', 'users', column: 'paciente_id'
end
