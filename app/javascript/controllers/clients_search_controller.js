import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]
  static values = {
    url: String
  }

  initialize() {
    this.submit = this.debounce(this.submit.bind(this), 300)
  }

  submit() {
    const form = this.formTarget
    const url = new URL(this.urlValue)
    const formData = new FormData(form)
    
    // Clear any existing params
    url.search = ''
    
    // Add form data to URL
    for (const [key, value] of formData.entries()) {
      if (value) url.searchParams.append(key, value)
    }

    // Fetch results
    fetch(url, {
      headers: {
        "Accept": "text/vnd.turbo-stream.html"
      }
    })
      .then(response => response.text())
      .then(html => {
        Turbo.renderStreamMessage(html)
      })
  }

  // Debounce helper to prevent too many requests
  debounce(func, wait) {
    let timeout
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout)
        func(...args)
      }
      clearTimeout(timeout)
      timeout = setTimeout(later, wait)
    }
  }

  // Handle input changes
  inputChanged() {
    this.submit()
  }
} 