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
        @pagy, @records = pagy(@rq.result)
        @records
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
        self.filters << Filter.new(model_class, attribute, options)
      end
    end

  end

  class Field
    attr_reader :name, :label, :icon, :options

    def initialize(name, label, icon, options)
      @name = name
      @label = label
      @icon = icon
      @options = options
    end
  end

  class SearchField < Field; end

  class SelectField < Field
    attr_reader :collection

    def initialize(name, label, icon, options, collection)
      super(name, label, icon, options.reverse_merge(include_blank: true))
      @collection = collection
    end
  end

  class Filter
    attr_reader :model_class, :attribute, :filter_fields, :collection, :icon, :options

    def initialize(model_class, attribute, options)
      @model_class = model_class
      @attribute = attribute.to_s

      @filter_fields = options.delete(:fields)
      @collection = options.delete(:collection)
      @icon = options.delete(:icon)
      @options = options
    end

    # TODO: TLA 5/5/2022 - Add multi-select (select2?)
    # TODO: TLA 5/5/2022 - Add date picker
    # TODO: TLA 5/5/2022 - Add time picker?

    # Array of ransack attributes (form field names) that should be collected to filter on the given attribute
    def fields(methods: nil)
      return filter_fields if filter_fields.present?

      @_fields ||= begin
        if collection.present?
          [SelectField.new("#{attribute}_i_cont", attribute.titleize, icon || 'search', options, collection)]
        elsif column = column_for(attribute)
          case column.type
          when :date, :datetime
            [
              SearchField.new("#{attribute}_gteq", attribute.titleize, icon || 'calendar-date', options.merge(placeholder: "From")),
              SearchField.new("#{attribute}_lteq", attribute.titleize, icon || 'calendar-date', options.merge(placeholder: "To"))
            ]
          when :integer, :float, :decimal
            [
              SearchField.new("#{attribute}_gteq", attribute.titleize, icon || '123', options.merge(placeholder: "From")),
              SearchField.new("#{attribute}_lteq", attribute.titleize, icon || '123', options.merge(placeholder: "To"))
            ]
          when :string, :text
            [SearchField.new("#{attribute}_i_cont", attribute.titleize, icon || 'search', options)]
          when :boolean
            [SelectField.new("#{attribute}_eq", attribute.titleize, icon, options, [true, false])]
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
