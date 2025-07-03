# より柔軟な商品管理（正規化したテーブル設計）
class CreateProductsNormalized < ActiveRecord::Migration[8.0]
  def change
    # 基本商品情報
    create_table :products do |t|
      t.string :title, null: false
      t.text :description
      t.json :features
      t.string :category
      t.string :brand
      t.string :image_url
      t.string :large_image_url
      t.json :search_keywords
      t.datetime :last_synced_at
      
      t.timestamps
    end
    
    # 各ECサイトでの商品情報
    create_table :product_listings do |t|
      t.references :product, null: false, foreign_key: true
      t.string :platform, null: false # 'amazon', 'rakuten', 'yahoo', etc.
      t.string :external_id # ASIN, itemCode, etc.
      t.string :product_url
      t.string :affiliate_url
      t.decimal :price, precision: 10, scale: 2
      t.string :price_currency, default: 'JPY'
      t.string :price_display
      t.boolean :prime_eligible, default: false
      t.string :shop_name
      t.integer :review_count, default: 0
      t.decimal :review_average, precision: 3, scale: 2
      t.json :platform_specific_data # プラットフォーム固有のデータ
      t.datetime :last_updated_at
      
      t.timestamps
    end
    
    add_index :product_listings, [:platform, :external_id], unique: true
    add_index :product_listings, :platform
  end
end