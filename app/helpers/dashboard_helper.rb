module DashboardHelper
  def order_status_color(order)
    case order.status
    when 'pending'
      'bg-yellow-100 text-yellow-800'
    when 'confirmed'
      'bg-blue-100 text-blue-800'
    when 'delivered'
      'bg-green-100 text-green-800'
    end
  end

  def order_tooltip(order)
    "#{order.client.name}\n#{number_to_currency(order.total_price)}\n#{order.delivery_date.strftime('%B %d, %Y')}"
  end

  def delivery_status_badge(order)
    base_classes = "px-2 py-1 text-xs font-medium rounded-full"
    case order.status
    when 'pending'
      "#{base_classes} bg-yellow-100 text-yellow-800"
    when 'confirmed'
      "#{base_classes} bg-blue-100 text-blue-800"
    when 'delivered'
      "#{base_classes} bg-green-100 text-green-800"
    end
  end
end
