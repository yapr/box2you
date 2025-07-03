# Amazonから取得した商品データを保存するテーブル
class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      # Amazon商品情報
      t.string :amazon_asin, index: true
      t.string :title, null: false
      t.text :description
      t.json :features # JSON配列として保存
      t.decimal :price_amount, precision: 10, scale: 2
      t.string :price_currency, default: 'JPY'
      t.string :price_display
      t.boolean :prime_eligible, default: false
      t.string :image_url
      t.string :large_image_url
      t.string :amazon_detail_url
      t.string :color
      t.string :size
      t.string :format
      t.integer :amazon_total_results
      
      # Rakuten商品情報
      t.string :rakuten_item_code, index: true
      t.string :rakuten_item_url
      t.string :rakuten_affiliate_url
      t.decimal :rakuten_price, precision: 10, scale: 2
      t.string :rakuten_shop_name
      t.integer :rakuten_review_count, default: 0
      t.decimal :rakuten_review_average, precision: 3, scale: 2
      
      # 共通フィールド
      t.string :category
      t.string :brand
      t.json :search_keywords # 検索で使用したキーワード
      t.datetime :last_synced_at # 最後にAPIから同期した時刻
      
      t.timestamps
    end
    
    add_index :products, [:amazon_asin, :rakuten_item_code], unique: true
    add_index :products, :last_synced_at
  end
end