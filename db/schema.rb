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

ActiveRecord::Schema[8.0].define(version: 2025_06_15_080027) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "book_translations", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.string "title", null: false
    t.string "author"
    t.text "summary"
    t.string "language", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "to_tsvector('english'::regconfig, (title)::text)", name: "idx_book_translations_title_gin", using: :gin
    t.index ["book_id", "language"], name: "index_book_translations_on_book_id_and_language", unique: true
    t.index ["book_id"], name: "index_book_translations_on_book_id"
    t.index ["language"], name: "index_book_translations_on_language"
  end

  create_table "books", force: :cascade do |t|
    t.string "isbn"
    t.integer "popularity_score", default: 0
    t.boolean "ai_summary_cached", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ai_summary_cached"], name: "index_books_on_ai_summary_cached"
    t.index ["isbn"], name: "index_books_on_isbn", unique: true
    t.index ["popularity_score"], name: "index_books_on_popularity_score"
  end

  add_foreign_key "book_translations", "books"
end
