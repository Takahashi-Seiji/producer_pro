import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "results"]
  static values = {
    url: String
  }

  initialize() {
    this.submit = this.debounce(this.submit.bind(this), 300)
  }

  connect() {
    // Optional: Perform initial search on connect
    // this.submit()
  }

  submit() {
    const form = this.formTarget
    const url = new URL(this.urlValue || form.action)
    const formData = new FormData(form)

    // Append form data to URL
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

  // Handle individual input changes
  inputChanged() {
    this.submit()
  }

  // Handle date changes
  dateChanged(event) {
    // Prevent immediate submission on date input to allow both dates to be selected
    if (event.target.name === "start_date" || event.target.name === "end_date") {
      const startDate = this.formTarget.querySelector("[name='start_date']").value
      const endDate = this.formTarget.querySelector("[name='end_date']").value
      
      if (startDate && endDate) {
        this.submit()
      }
    }
  }
} 