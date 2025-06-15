import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
  static targets = ["input", "results"]
  static values = { url: String }

  connect() {
    this.timeout = null
  }

  search() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      const query = this.inputTarget.value.trim()
      
      if (query.length > 0) {
        this.performSearch(query)
      } else {
        this.clearResults()
      }
    }, 300)
  }

  async performSearch(query) {
    try {
      const response = await fetch(`${this.urlValue}?q=${encodeURIComponent(query)}`, {
        headers: {
          "Accept": "application/json",
          "X-Requested-With": "XMLHttpRequest"
        }
      })
      
      if (response.ok) {
        const results = await response.json()
        this.displayResults(results)
      }
    } catch (error) {
      console.error("Search failed:", error)
    }
  }

  displayResults(results) {
    if (this.hasResultsTarget) {
      this.resultsTarget.innerHTML = results.map(result => 
        `<a href="/books/${result.book_id}" class="block p-3 hover:bg-gray-50 border-b">
          <div class="font-medium">${result.title}</div>
          ${result.author ? `<div class="text-sm text-gray-600">${result.author}</div>` : ''}
        </a>`
      ).join('')
      this.resultsTarget.classList.remove('hidden')
    }
  }

  clearResults() {
    if (this.hasResultsTarget) {
      this.resultsTarget.innerHTML = ''
      this.resultsTarget.classList.add('hidden')
    }
  }

  hideResults() {
    setTimeout(() => {
      this.clearResults()
    }, 200) // Delay to allow click on results
  }
}
