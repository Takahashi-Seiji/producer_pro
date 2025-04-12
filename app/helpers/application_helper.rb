module ApplicationHelper
  def order_status_badge(order)
    color_class = case order.status
    when 'pending'
      'bg-yellow-100 text-yellow-800'
    when 'processing'
      'bg-blue-100 text-blue-800'
    when 'completed'
      'bg-green-100 text-green-800'
    when 'cancelled'
      'bg-red-100 text-red-800'
    else
      'bg-gray-100 text-gray-800'
    end

    content_tag(:span, order.status.titleize, class: "px-3 py-1 rounded-full #{color_class} text-sm font-medium")
  end

  def order_status_color(order)
    case order.status
    when 'pending'
      'text-yellow-600'
    when 'processing'
      'text-blue-600'
    when 'completed'
      'text-green-600'
    when 'cancelled'
      'text-red-600'
    else
      'text-gray-600'
    end
  end
end
