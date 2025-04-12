import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]
  static values = {
    url: String,
    section: String
  }

  initialize() {
    this.submit = this.debounce(this.submit.bind(this), 300)
  }

  submit() {
    const form = this.formTarget
    const url = new URL(this.urlValue)
    const currentParams = new URLSearchParams(window.location.search)
    const formData = new FormData(form)
    const section = formData.get('section')
    
    // Preserve other section's search parameters
    for (const [key, value] of currentParams.entries()) {
      // Only keep parameters from the other section
      if (key === 'section' && value !== section) {
        url.searchParams.append(key, value)
      }
      if (key === 'search' && currentParams.get('section') !== section) {
        url.searchParams.append('search', value)
        url.searchParams.append('section', currentParams.get('section'))
      }
    }
    
    // Add current section's parameters
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