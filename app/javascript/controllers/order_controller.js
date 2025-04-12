import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["items", "total"]

  connect() {
    this.updateTotal()
  }

  addItem(event) {
    event.preventDefault()
    const template = this.itemTemplate()
    this.itemsTarget.insertAdjacentHTML('beforeend', template)
    this.updateTotal()
  }

  removeItem(event) {
    event.preventDefault()
    const item = event.target.closest('.order-item')
    const destroyInput = item.querySelector('input[name*="_destroy"]')
    if (destroyInput) {
      destroyInput.value = '1'
      item.style.display = 'none'
    } else {
      item.remove()
    }
    this.updateTotal()
  }

  updatePrice(event) {
    const select = event.target
    const item = select.closest('.order-item')
    const unitPriceField = item.querySelector('input[name*="unit_price"]')
    const selectedOption = select.options[select.selectedIndex]
    const product = this.getProduct(select.value)
    
    if (product) {
      unitPriceField.value = product.price_per_unit
      this.updateItemTotal(item)
    } else {
      unitPriceField.value = ''
    }
    
    this.updateTotal()
  }

  updateTotal() {
    const total = Array.from(this.element.querySelectorAll('.order-item'))
      .filter(item => item.style.display !== 'none')
      .reduce((sum, item) => {
        const quantity = parseFloat(item.querySelector('input[name*="quantity"]').value) || 0
        const unitPrice = parseFloat(item.querySelector('input[name*="unit_price"]').value) || 0
        const itemTotal = quantity * unitPrice
        item.querySelector('.item-total').textContent = `$${itemTotal.toFixed(2)}`
        return sum + itemTotal
      }, 0)
    
    this.element.querySelector('#order-total').textContent = `$${total.toFixed(2)}`
  }

  itemTemplate() {
    const timestamp = new Date().getTime()
    return `
      <tr class="order-item">
        <td class="px-4 py-2">
          <select name="order[order_items_attributes][${timestamp}][product_id]"
                  class="w-full rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:outline-none px-3 py-1 text-sm bg-white text-gray-800"
                  data-action="change->order#updatePrice">
            <option value="">Select a product</option>
            ${this.productOptions()}
          </select>
        </td>
        <td class="px-4 py-2">
          <input type="number" name="order[order_items_attributes][${timestamp}][quantity]"
                 class="w-24 rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:outline-none px-3 py-1 text-sm bg-white text-gray-800"
                 min="1" value="1" data-action="change->order#updateTotal">
        </td>
        <td class="px-4 py-2">
          <input type="number" name="order[order_items_attributes][${timestamp}][unit_price]"
                 class="w-24 rounded-lg border border-gray-300 bg-gray-50 px-3 py-1 text-sm text-gray-800"
                 step="0.01" readonly>
        </td>
        <td class="px-4 py-2">
          <span class="item-total text-sm text-gray-900">$0.00</span>
        </td>
        <td class="px-4 py-2">
          <button type="button" class="text-red-600 hover:text-red-800" data-action="click->order#removeItem">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
            </svg>
          </button>
        </td>
      </tr>
    `
  }

  productOptions() {
    return Array.from(document.querySelector('select[name*="product_id"]').options)
      .map(option => `<option value="${option.value}">${option.text}</option>`)
      .join('')
  }

  getProduct(id) {
    const select = document.querySelector('select[name*="product_id"]')
    const option = select.querySelector(`option[value="${id}"]`)
    if (option) {
      return {
        id: id,
        name: option.text,
        price_per_unit: parseFloat(option.dataset.price) || 0
      }
    }
    return null
  }
} 