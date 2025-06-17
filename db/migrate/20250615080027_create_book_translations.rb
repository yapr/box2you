class CreateBookTranslations < ActiveRecord::Migration[8.0]
  def change
    create_table :book_translations do |t|
      t.references :book, null: false, foreign_key: true
      t.string :title, null: false
      t.string :author
      t.text :summary
      t.string :language, null: false

      t.timestamps
    end
    add_index :book_translations, :language
    add_index :book_translations, [ :book_id, :language ], unique: true

    # Full text search index for title
    execute "CREATE INDEX idx_book_translations_title_gin ON book_translations USING gin(to_tsvector('english', title));"
  end
end
