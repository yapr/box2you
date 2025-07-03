require "vacuum"

class AmazonProductService
  attr_reader :client

  def initialize
    # FIXME: Make sure to set up your Amazon PA-API credentials first
    unless AmazonPaapiConfig.configured?
      raise "Amazon PA-API credentials not configured. Please set up your credentials."
    end

    @client = Vacuum.new(
      access_key: AmazonPaapiConfig.access_key,
      secret_key: AmazonPaapiConfig.secret_key,
      partner_tag: AmazonPaapiConfig.associate_tag,
      marketplace: AmazonPaapiConfig.marketplace
    )
    
    Rails.logger.info "Amazon PA-API initialized with marketplace: #{AmazonPaapiConfig.marketplace}"
  end

  # デバッグ用メソッド
  def test_api_connection
    begin
      # 最小限のリクエストでAPIをテスト
      response = client.get_items(
        item_ids: ["B0D3KSFZ9Q"],
        resources: ["ItemInfo.Title"]
      )
      Rails.logger.info "Test API Response: #{response.inspect}"
      response
    rescue StandardError => e
      Rails.logger.error "API Test Error: #{e.message}"
      Rails.logger.error "Error class: #{e.class}"
      Rails.logger.error "Backtrace: #{e.backtrace.join("\n")}"
      e
    end
  end

  # 認証情報の確認用メソッド
  def check_credentials
    {
      access_key_present: AmazonPaapiConfig.access_key.present?,
      access_key_length: AmazonPaapiConfig.access_key&.length,
      secret_key_present: AmazonPaapiConfig.secret_key.present?,
      secret_key_length: AmazonPaapiConfig.secret_key&.length,
      associate_tag_present: AmazonPaapiConfig.associate_tag.present?,
      associate_tag: AmazonPaapiConfig.associate_tag,
      marketplace: AmazonPaapiConfig.marketplace
    }
  end

  def search_items(keywords, options = {})
    return { error: "Keywords are required" } if keywords.blank?

    begin
      response = client.search_items(
        keywords: keywords,
        resources: [
          "Images.Primary.Medium",
          "Images.Primary.Large",
          "ItemInfo.Title",
          "ItemInfo.Features",
          "ItemInfo.ProductInfo",
          "ItemInfo.TechnicalInfo",
          "Offers.Listings.Price",
          "Offers.Listings.DeliveryInfo.IsPrimeEligible",
          "Offers.Summaries.HighestPrice",
          "Offers.Summaries.LowestPrice"
        ],
        search_index: options[:search_index] || "All",
        item_count: options[:item_count] || 10,
        item_page: options[:item_page] || 1
      )
      parse_search_response(response)
    rescue StandardError => e
      Rails.logger.error "Amazon API Error: #{e.message}"
      { error: "Amazon API Error: #{e.message}" }
    end
  end

  def get_item(asin)
    return { error: "ASIN is required" } if asin.blank?

    begin
      response = client.get_items(
        item_ids: [asin],
        resources: [
          "Images.Primary.Medium",
          "Images.Primary.Large", 
          "ItemInfo.Title",
          "ItemInfo.Features",
          "ItemInfo.ProductInfo",
          "ItemInfo.TechnicalInfo",
          "Offers.Listings.Price",
          "Offers.Listings.DeliveryInfo.IsPrimeEligible",
          "Offers.Summaries.HighestPrice",
          "Offers.Summaries.LowestPrice"
        ]
      )
      
      # デバッグ用：レスポンス全体をログ出力
      Rails.logger.info "Amazon API Response: #{response.inspect}"
      
      parse_item_response(response)
    rescue StandardError => e
      Rails.logger.error "Amazon API Error: #{e.message}"
      Rails.logger.error "Error backtrace: #{e.backtrace.join("\n")}"
      { error: "Amazon API Error: #{e.message}" }
    end
  end

  private

  def parse_search_response(response)
    # HTTPレスポンスオブジェクトの場合、JSONをパース
    if response.respond_to?(:status)
      Rails.logger.info "Search HTTP Status: #{response.status}"
      Rails.logger.info "Search Response Body: #{response.body}"
      
      if response.status.to_i != 200
        return { error: "Amazon Search API Error: HTTP #{response.status}" }
      end
      
      # レスポンスボディをパース
      begin
        body_string = response.body.to_s
        # 文字エンコーディングを強制的にUTF-8に設定
        body_string = body_string.force_encoding('UTF-8') unless body_string.valid_encoding?
        response = JSON.parse(body_string)
      rescue JSON::ParserError => e
        Rails.logger.error "JSON Parse Error: #{e.message}"
        return { error: "Invalid JSON response from Amazon API" }
      end
    end
    
    return { error: "No results found" } unless response.dig("SearchResult", "Items")

    items = response["SearchResult"]["Items"].map do |item|
      parse_item_data(item)
    end.compact

    {
      items: items,
      total_results: response.dig("SearchResult", "TotalResultCount"),
      search_url: response.dig("SearchResult", "SearchURL")
    }
  end

  def parse_item_response(response)
    Rails.logger.info "Response structure: #{response.keys}" if response.is_a?(Hash)
    
    # HTTPレスポンスオブジェクトの場合、JSONをパース
    if response.respond_to?(:status)
      Rails.logger.error "HTTP Status: #{response.status}"
      Rails.logger.error "Response Body: #{response.body}" # レスポンスボディも表示
      
      if response.status.to_i == 401
        return { error: "認証エラー: Amazon PA-APIの認証情報を確認してください" }
      elsif response.status.to_i == 400
        # 400エラーの詳細を表示
        begin
          error_body = JSON.parse(response.body.to_s)
          Rails.logger.error "Error Details: #{error_body.inspect}"
          if error_body.dig("Errors")
            errors = error_body["Errors"]
            return { error: "Bad Request: #{errors.map { |e| e['Message'] }.join(', ')}" }
          end
        rescue JSON::ParserError
          # JSONパースできない場合はそのままエラーメッセージ
        end
        return { error: "Amazon API Error: HTTP 400 Bad Request" }
      elsif response.status.to_i != 200
        return { error: "Amazon API Error: HTTP #{response.status}" }
      end
      
      # レスポンスボディをパース
      begin
        body_string = response.body.to_s
        # 文字エンコーディングを強制的にUTF-8に設定
        body_string = body_string.force_encoding('UTF-8') unless body_string.valid_encoding?
        response = JSON.parse(body_string)
      rescue JSON::ParserError => e
        Rails.logger.error "JSON Parse Error: #{e.message}"
        return { error: "Invalid JSON response from Amazon API" }
      end
    end
    
    # エラーが含まれているかチェック
    if response.dig("Errors")
      errors = response["Errors"]
      Rails.logger.error "Amazon API Errors: #{errors.inspect}"
      return { error: "Amazon API returned errors: #{errors.map { |e| e['Message'] }.join(', ')}" }
    end
    
    # アイテムが見つからない場合の詳細チェック
    unless response.dig("ItemsResult", "Items")
      Rails.logger.warn "ItemsResult structure: #{response.dig('ItemsResult')&.keys}"
      return { error: "Item not found" }
    end

    item = response["ItemsResult"]["Items"].first
    { item: parse_item_data(item) }
  end

  def parse_item_data(item)
    return nil unless item

    title = item.dig("ItemInfo", "Title", "DisplayValue")
    
    {
      asin: item["ASIN"],
      title: title,
      features: extract_features(item),
      price: extract_price(item),
      prime_eligible: item.dig("Offers", "Listings", 0, "DeliveryInfo", "IsPrimeEligible"),
      image_url: item.dig("Images", "Primary", "Medium", "URL"),
      large_image_url: item.dig("Images", "Primary", "Large", "URL"),
      detail_page_url: item["DetailPageURL"],
      color: item.dig("ItemInfo", "ProductInfo", "Color", "DisplayValue"),
      size: item.dig("ItemInfo", "ProductInfo", "Size", "DisplayValue"),
      format: extract_format(item),
      # 楽天・その他ECサイトのURL生成
      rakuten_url: title ? ProductUrlService.generate_rakuten_search_url(title, RakutenConfig.affiliate_id) : nil,
      yahoo_url: title ? ProductUrlService.generate_yahoo_search_url(title) : nil,
      price_comparison_url: title ? ProductUrlService.generate_price_comparison_url(title) : nil
    }
  end

  def extract_features(item)
    features = item.dig("ItemInfo", "Features", "DisplayValues")
    return [] unless features

    features.first(5) # 最初の5つの特徴のみ
  end

  def extract_price(item)
    price_info = item.dig("Offers", "Listings", 0, "Price")
    return nil unless price_info

    {
      amount: price_info.dig("Amount"),
      currency: price_info.dig("Currency"),
      display_amount: price_info.dig("DisplayAmount")
    }
  end

  def extract_format(item)
    formats = item.dig("ItemInfo", "TechnicalInfo", "Formats", "DisplayValues")
    return nil unless formats

    formats.first
  end
end
