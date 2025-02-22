# Helpers to create action links. This default implementation supports
# regular links with an icon and a label. To change the general style
# of action links, change the method #action_link, e.g. to generate a button.
# The common crud actions show, edit, destroy, index and add are provided here.
module ActionsHelper

  # A generic helper method to create action links.
  # These link could be styled to look like buttons, for example.
  def action_link(label, icon = nil, url = {}, html_options = {})
    add_css_class html_options, 'action btn btn-outline-primary ms-2'
    link_to(icon ? action_icon(icon, label) : label,
            url, html_options)
  end

  def action_button(label, icon = nil, url = {}, html_options = {})
    html_options.reverse_merge!({ form: { class: 'd-inline-block ms-2' } })
    add_css_class html_options, 'action btn btn-outline-primary'
    label = action_icon(icon, label) if icon
    button_to(label, url, html_options)
  end

  # Outputs an icon for an action with an optional label.
  def action_icon(icon, label = nil)
    html = content_tag(:i, '', class: "bi bi-#{icon}")
    html << ' ' << label if label
    html
  end

  # Standard show action to the given path.
  # Uses the current +entry+ if no path is given.
  def show_action_link(path = nil)
    return unless policy(entry).show?

    path ||= path_args(entry)
    action_link(ti('link.show'), 'zoom-in', path)
  end

  # Standard edit action to given path.
  # Uses the current +entry+ if no path is given.
  def edit_action_link(path = nil)
    return unless policy(entry).edit?

    path ||= path_args(entry)
    path = path.is_a?(String) ? path : edit_polymorphic_path(path)
    action_link(ti('link.edit'), 'pencil', path)
  end

  # Standard destroy action to the given path.
  # Uses the current +entry+ if no path is given.
  def destroy_action_link(path = nil)
    return unless policy(entry).destroy?

    path ||= path_args(entry)
    action_button(ti('link.delete'), 'trash', path,
                {
                  data: { confirm: ti(:confirm_delete, model: models_label(plural: false)) },
                  method: :delete,
                  class: 'btn-outline-danger'
                })
  end

  # Standard list action to the given path.
  # Uses the current +model_class+ if no path is given.
  def index_action_link(path = nil, url_options = { returning: true })
    return unless policy(model_class).index?

    path ||= path_args(model_class)
    path = path.is_a?(String) ? path : polymorphic_path(path, url_options)
    action_link(ti('link.list'), 'list', path)
  end

  # Standard add action to given path.
  # Uses the current +model_class+ if no path is given.
  def add_action_link(path = nil, url_options = {})
    return unless policy(model_class).new?

    path ||= path_args(model_class)
    path = path.is_a?(String) ? path : new_polymorphic_path(path, url_options)
    action_link(I18n.t(:add, scope: %i[list index], label: models_label(plural: false)), 'plus-lg', path, title: "Add a new #{models_label(plural: false).downcase}")
  end

end
