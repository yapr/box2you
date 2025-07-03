import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["title", "rakutenLink", "yahooLink", "priceLink"]
  static values = { 
    affiliateId: String,
    productTitle: String 
  }

  connect() {
    if (this.productTitleValue) {
      this.generateLinks()
    }
  }

  generateLinks() {
    const title = this.productTitleValue
    const keywords = this.extractKeywords(title)
    
    // 楽天リンク生成
    if (this.hasRakutenLinkTarget) {
      this.rakutenLinkTarget.href = this.generateRakutenUrl(keywords)
    }
    
    // Yahoo!ショッピングリンク生成
    if (this.hasYahooLinkTarget) {
      this.yahooLinkTarget.href = this.generateYahooUrl(keywords)
    }
    
    // 価格比較サイトリンク生成
    if (this.hasPriceLinkTarget) {
      this.priceLinkTarget.href = this.generatePriceComparisonUrl(keywords)
    }
  }

  extractKeywords(title) {
    return title
      .replace(/【.*?】/g, '') // 【】内を除去
      .replace(/\(.*?\)/g, '') // ()内を除去
      .replace(/\[.*?\]/g, '') // []内を除去
      .replace(/-.*/, '')      // ハイフン以降を除去
      .trim()
      .split(/\s+/)
      .slice(0, 3)             // 最初の3つの単語
      .join(' ')
  }

  generateRakutenUrl(keywords) {
    const encodedKeywords = encodeURIComponent(keywords)
    const baseUrl = `https://search.rakuten.co.jp/search/mall/${encodedKeywords}/`
    
    if (this.affiliateIdValue) {
      return `${baseUrl}?f=1&grp=product&scid=af_pc_${this.affiliateIdValue}`
    }
    return baseUrl
  }

  generateYahooUrl(keywords) {
    const encodedKeywords = encodeURIComponent(keywords)
    return `https://shopping.yahoo.co.jp/search?p=${encodedKeywords}`
  }

  generatePriceComparisonUrl(keywords) {
    const encodedKeywords = encodeURIComponent(keywords)
    return `https://kakaku.com/search_results/${encodedKeywords}/`
  }

  // リンクを動的に更新（検索結果で商品タイトルが変わった場合など）
  updateLinks(event) {
    const newTitle = event.target.textContent || event.detail.title
    this.productTitleValue = newTitle
    this.generateLinks()
  }
}