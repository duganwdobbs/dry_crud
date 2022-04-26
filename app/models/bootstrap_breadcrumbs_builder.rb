# The BootstrapBuilder is an augmented version of the default breadcrumb builder.
# It provides basic functionalities to render a breadcrumb navigation with defaults
# relevant to a bootstrap 5 breadcrumb.
#
# The BootstrapBuilder accepts :tag and :classes options.
# The :tag will wrap the anchor tag, and the :classes will be added to the :tag
# To use this, pass the option `builder: BootstrapBreadcrumbsBuilder` to the <tt>render_breadcrumbs</tt> helper method.
class BootstrapBreadcrumbsBuilder < BreadcrumbsOnRails::Breadcrumbs::Builder

  def initialize(context, elements, options = {})
    @context  = context
    @elements = elements
    @options  = options.reverse_merge({
      wrapper_tag: :ol,
      wrapper_class: 'breadcrumb',
      separator: '',
      tag: :li,
      tag_class: 'breadcrumb-item'
    })
  end

  def render
    @context.content_tag(@options[:wrapper_tag], class: @options[:wrapper_class]) do
      @elements.collect do |element|
        render_element(element)
      end.join(@options[:separator]).html_safe
    end
  end

  def render_element(element)
    if element.path == nil
      content = compute_name(element)
    else
      content = @context.link_to_unless_current(compute_name(element), compute_path(element), element.options)
    end

    @context.content_tag(@options[:tag], content, class: @options[:tag_class])
  end

end
