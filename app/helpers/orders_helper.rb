module OrdersHelper
  def order_status_badge(order)
    case order.status
    when 'delivered'
      'inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800'
    when 'confirmed'
      'inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800'
    when 'cancelled'
      'inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-red-100 text-red-800'
    else
      'inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800'
    end
  end
end
