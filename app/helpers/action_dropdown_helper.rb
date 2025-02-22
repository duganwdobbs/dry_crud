module ActionDropdownHelper
  include ActionsHelper

  def action_dropdown(label, icon = nil, options = [], html_options = {}, config = {})
    content = icon ? action_icon(icon, label) : label
    render 'shared/action_dropdown', content: content, options: options, html_options: html_options, config: config
  end

  def action_dropdown_button(label, icon = nil, options = [], html_options = {}, btn_type: 'gold')
    content = icon ? action_icon(icon, label) : label
    render 'shared/action_dropdown_button', content: content, options: options, html_options: html_options, btn_type: btn_type
  end

  def action_dropdown_checkbox(label, f, field, values_hash = [])
    raise 'You need to send the form object to action_dropdown_checkbox.' if f.blank?

    render 'shared/action_dropdown_checkbox', content: label, f: f, field: field, values_hash: values_hash
  end
end
