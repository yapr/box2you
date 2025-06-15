class CreateBooks < ActiveRecord::Migration[8.0]
  def change
    create_table :books do |t|
      t.string :isbn
      t.integer :popularity_score, default: 0
      t.boolean :ai_summary_cached, default: false

      t.timestamps
    end
    add_index :books, :isbn, unique: true
    add_index :books, :popularity_score
    add_index :books, :ai_summary_cached
  end
end
