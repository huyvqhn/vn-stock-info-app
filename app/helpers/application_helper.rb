module ApplicationHelper
  def display_billion(val)
    v = val.to_f / 1_000_000_000
    if v.abs >= 0.001
      "#{number_with_delimiter(v.round(3))}<span style='color:#888;font-size:0.95em;'>B</span>".html_safe
    else
      number_with_delimiter(val.to_i)
    end
  end
end
