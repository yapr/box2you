class AmazonProductsController < ApplicationController
  before_action :check_amazon_credentials

  def index
    @products = []
    @search_term = params[:search]
    @total_results = 0
    @current_page = params[:page]&.to_i || 1

    if @search_term.present?
      begin
        service = AmazonProductService.new
        result = service.search_items(
          @search_term,
          search_index: params[:search_index] || 'All',
          item_count: 10,
          item_page: @current_page
        )

        if result[:error]
          flash.now[:alert] = result[:error]
        else
          @products = result[:items] || []
          @total_results = result[:total_results] || 0
          @search_url = result[:search_url]
        end
      rescue StandardError => e
        Rails.logger.error "Amazon search error: #{e.message}"
        flash.now[:alert] = "検索中にエラーが発生しました: #{e.message}"
      end
    end
  end

  def show
    @asin = params[:id]
    
    begin
      service = AmazonProductService.new
      result = service.get_item(@asin)

      if result[:error]
        flash.now[:alert] = result[:error]
        redirect_to amazon_products_path
      else
        @product = result[:item]
      end
    rescue StandardError => e
      Rails.logger.error "Amazon item fetch error: #{e.message}"
      flash[:alert] = "商品情報の取得中にエラーが発生しました: #{e.message}"
      redirect_to amazon_products_path
    end
  end

  private

  def check_amazon_credentials
    # FIXME: Amazon credentials not configured yet
    unless AmazonPaapiConfig.configured?
      flash[:alert] = 'Amazon PA-API credentials are not configured. Please set up your credentials first.'
      redirect_to root_path
    end
  end
end
