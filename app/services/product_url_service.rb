class ProductUrlService
  def self.generate_rakuten_search_url(product_title, affiliate_id = nil)
    # 商品名から検索キーワードを生成
    keywords = extract_keywords(product_title)
    encoded_keywords = URI.encode_www_form_component(keywords)
    
    base_url = "https://search.rakuten.co.jp/search/mall/#{encoded_keywords}/"
    
    # アフィリエイトIDがある場合は追加
    if affiliate_id.present?
      "#{base_url}?f=1&grp=product&scid=af_pc_#{affiliate_id}"
    else
      base_url
    end
  end
  
  def self.generate_yahoo_search_url(product_title)
    keywords = extract_keywords(product_title)
    encoded_keywords = URI.encode_www_form_component(keywords)
    "https://shopping.yahoo.co.jp/search?p=#{encoded_keywords}"
  end
  
  def self.generate_price_comparison_url(product_title)
    keywords = extract_keywords(product_title)
    encoded_keywords = URI.encode_www_form_component(keywords)
    "https://kakaku.com/search_results/#{encoded_keywords}/"
  end
  
  private
  
  def self.extract_keywords(title)
    # タイトルから検索に使えるキーワードを抽出
    title
      .gsub(/【.*?】/, '') # 【】内を除去
      .gsub(/\(.*?\)/, '') # ()内を除去
      .gsub(/\[.*?\]/, '') # []内を除去
      .gsub(/-.*/, '')     # ハイフン以降を除去
      .strip
      .split(/\s+/)
      .first(3)            # 最初の3つの単語まで
      .join(' ')
  end
end