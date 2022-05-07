# Use tabs to build a Bootstrap 5 tab navigation section.
# By default, the first tab will be active.
#
# To have another tab active on load, set default_tab in options or params['tab'] to the id of the desired tab.
# params[:tab] will override the options[:default_tab]
#
# tabs accepts options for :default_tab and :class
#
# t.tab :link and :content options
# e.g.
#   t.tab content: { class: 'hmm' }, link: { class: 'hmm' }
#
#   link.class adds the class to div.nav-link (the tab itself)
#   content.class adds the class to the div.tab-content (the content pane)
#
#
# Example Usage in a slim file:
#
# = tabs do |t|
#   - t.tab :info, "Info" do
#     = render 'crud/attrs'
#   - t.tab :locations, "Locations" do
#     a.action.btn.ms-2.btn-gold.float-end href=new_admin_region_location_path(entry)
#       .bi.bi-plus-lg Location
#     = plain_table_or_message(entry.locations, :code, :name, :description) do |t|
#      - t.col('') { |location| link_to('', [:edit, :admin, entry, location], class: 'bi bi-pencil') }
#
# It's also possible to render the tab bar and tab panes separately:
#
# / Create the builder
# - builder = tabs_builder do |t|
#   - t.tab :info, "Info" do
#     ...
#
# / Render the parts later in the view
# = b.tab_bar_to_html
# p Add other stuff between, etc.
# = b.tab_pane_to_html
#

module TabsHelper
  def tabs(options = {})
    builder = Builder.new(self, options)
    yield builder
    builder.to_html
  end

  def tabs_builder(options = {})
    builder = Builder.new(self, options)
    yield builder
    builder
  end

  class Builder
    def initialize(context, options)
      @context = context
      @options = options
      @tabs = []
      @downcased_ids = []
    end

    def tab id, label, options = {}, &block
      tabs << { id: id, label: label, options: options, block: block }
      downcased_ids << id.to_s.downcase
    end

    def to_html
      tab_bar_to_html + tab_pane_to_html
    end

    def tab_bar_to_html
      tag.ul(class: "nav nav-tabs") do
        tabs.each_with_index do |tab, i|
          concat render_tab(tab[:id], tab[:label], tab.dig(:options, :link))
        end
      end
    end

    def tab_pane_to_html
      classes = ['tab-content']
      classes += options[:class].split(" ") if options[:class].present?
      tag.div(class: classes.join(' ')) do
        tabs.each_with_index do |tab, i|
          concat render_tab_pane(tab[:id], tab.dig(:options, :content), &tab[:block])
        end
      end
    end

    private

    attr_reader :context, :options
    attr_accessor :tabs, :downcased_ids

    delegate :tag, :content_tag, :concat, :params, to: :context

    def is_active?(id)
      target = params[:tab].presence || options[:default_tab].presence
      target = downcased_ids.first if target.blank? || !downcased_ids.include?(target.to_s.downcase)
      target.to_s.downcase == id.to_s.downcase
    end

    def render_tab(id, label, options)
      tag.li(class: 'nav-item') do
        classes = %w[nav-link]
        classes += options[:class].split(" ") if options.present?
        classes << 'active' if is_active?(id)
        tag.button(class: classes.join(' '), type:"button", 'data-bs-toggle':"tab", 'data-bs-target':"##{id}-tab") do
          label
        end
      end
    end

    def render_tab_pane(id, options)
      classes = %w[tab-pane fade]
      classes += options[:class].split(" ") if options.present?
      classes += %w[show active] if is_active?(id)
      tag.div(class: classes.join(' '), id: "#{id}-tab") do
        yield if block_given?
      end
    end
  end
end
