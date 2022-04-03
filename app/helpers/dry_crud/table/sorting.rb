module DryCrud
  module Table

    # Provides headers with sort links. Expects a method :sortable?(attr)
    # in the template/controller to tell if an attribute is sortable or not.
    # Extracted into an own module for convenience.
    module Sorting

      # Create a header with sort links and a mark for the current sort
      # direction.
      def sort_header(attr, label = nil)
        label ||= attr_header(attr)
        template.link_to(sort_params(attr), class: 'text-decoration-none') do
          tag.span(label) + current_mark(attr)
        end
      end

      # Same as :attrs, except that it renders a sort link in the header
      # if an attr is sortable.
      def sortable_attrs(*attrs)
        attrs.each { |a| sortable_attr(a) }
      end

      # Renders a sort link header, otherwise similar to :attr.
      def sortable_attr(attr, header = nil, html_options = {}, &block)
        if template.sortable?(attr)
          attr(attr, sort_header(attr, header), html_options, &block)
        else
          attr(attr, header, &block)
        end
      end

      private

      # Request params for the sort link.
      def sort_params(attr)
        result = params.respond_to?(:to_unsafe_h) ? params.to_unsafe_h : params
        result.merge(sort: attr, sort_dir: sort_dir(attr), only_path: true)
      end

      # The sort mark, if any, for the given attribute.
      def current_mark(attr)
        icon = if current_sort?(attr)
          sort_dir(attr) == 'asc' ? 'sort-up' : 'sort-down'

        else
          'list'
        end

        tag.i('', class: "bi bi-#{icon} ms-2")
      end

      # Returns true if the given attribute is the current sort column.
      def current_sort?(attr)
        params[:sort] == attr.to_s
      end

      # The sort direction to use in the sort link for the given attribute.
      def sort_dir(attr)
        current_sort?(attr) && params[:sort_dir] == 'asc' ? 'desc' : 'asc'
      end

      # Delegate to template.
      def params
        template.params
      end

    end
  end
end
