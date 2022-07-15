module DryCrud

  # The filter functionality for the index table.
  # Define an array of DryCrud::Filter objects in your subclassing
  # controllers using the class attribute +filters+.
  module Filterable

    extend ActiveSupport::Concern

    included do
      class_attribute :filters
      self.filters = []

      helper_method :filter_support?, :filters

      prepend Prepends
    end

    # Prepended methods for filtering.
    module Prepends

      private

      # Enhance the list entries with an optional search criteria
      def list_entries
        @rq = super.ransack(params[:rq], search_key: :rq)
        @rq.result
      end

      # Returns true if this controller has searchable columns.
      def filter_support?
        filters.present?
      end
    end

    # Class methods for Filterable.
    module ClassMethods
      # Use this to add a filter to a CrudController
      #
      # => For example
      # class PersonController < CrudController
      #   self.add_filter(:name, collection: %w[Bob Sally Jane])
      #   ...
      #
      def add_filter(attribute, options = {})
        html_options = options.delete(:html_options)
        # Use a setter here (+=) in stead of a mutator like << so we don't
        # modify the superclass's version of filters - see the class_attribute documentation for more.
        self.filters += [Filter.new(model_class, attribute, options, html_options)]
      end
    end

  end

  class Field
    attr_reader :name, :label, :icon, :options, :html_options

    def initialize(name, label, icon, options, html_options)
      @name = name
      @label = label
      @icon = icon
      @options = options || {}
      @html_options = html_options || {}
    end
  end

  class SearchField < Field; end

  class SelectField < Field
    attr_reader :collection

    def initialize(name, label, icon, options, html_options, collection)
      super(name, label, icon, options.reverse_merge(include_blank: true), html_options)
      @collection = collection
    end
  end

  class Filter
    attr_reader :model_class, :attribute, :filter_fields, :collection, :icon, :options, :html_options

    def initialize(model_class, attribute, options, html_options)
      @model_class = model_class
      @attribute = attribute.to_s

      @filter_fields = options.delete(:fields)
      @collection = options.delete(:collection)
      @icon = options.delete(:icon)
      @options = options
      @html_options = html_options || {}
    end

    # Array of Field objects (subclasses) that should be collected to filter on the given attribute
    def fields(methods: nil)
      return filter_fields if filter_fields.present?

      @_fields ||= begin
        if collection.present?
          multiple = options.delete(:multiple)
          if multiple
            [SelectField.new("#{attribute}_i_cont_any", attribute.titleize, icon || 'search', options, html_options.merge(multiple: true), collection)]
          else
            [SelectField.new("#{attribute}_i_cont", attribute.titleize, icon || 'search', options, html_options, collection)]
          end
        elsif (column = column_for(attribute))
          case column.type
          when :date
            [
              SearchField.new("#{attribute}_gteq", "#{attribute.titleize} (From)", icon || 'calendar-date', options, html_options.merge(placeholder: "From", type: :date)),
              SearchField.new("#{attribute}_lteq", "#{attribute.titleize} (To)", icon || 'calendar-date', options, html_options.merge(placeholder: "To", type: :date))
            ]
          when :datetime
            [
              SearchField.new("#{attribute}_gteq", "#{attribute.titleize} (From)", icon || 'clock', options, html_options.merge(type: 'datetime-local')),
              SearchField.new("#{attribute}_lteq", "#{attribute.titleize} (To)", icon || 'clock', options, html_options.merge(type: 'datetime-local'))
            ]
          when :time
            [
              SearchField.new("#{attribute}_gteq", "#{attribute.titleize} (From)", icon || 'clock', options, html_options.merge(placeholder: "From", type: :time)),
              SearchField.new("#{attribute}_lteq", "#{attribute.titleize} (To)", icon || 'clock', options, html_options.merge(placeholder: "To", type: :time))
            ]
          when :integer, :float, :decimal
            [
              SearchField.new("#{attribute}_gteq", attribute.titleize, icon || '123', options, html_options.merge(placeholder: "From")),
              SearchField.new("#{attribute}_lteq", attribute.titleize, icon || '123', options, html_options.merge(placeholder: "To"))
            ]
          when :string, :text, :citext
            [SearchField.new("#{attribute}_i_cont", attribute.titleize, icon || 'search', options, html_options)]
          when :boolean
            [SelectField.new("#{attribute}_eq", attribute.titleize, icon, options, html_options, [true, false])]
          end
        else
          []
        end
      end
    end

    private

    def column_for(method)
      model_class.columns_hash[method.to_s] if model_class.respond_to? :columns_hash
    end
  end
end
