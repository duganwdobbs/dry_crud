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
      # TODO: TLA 5/2/2022 - See serchable and add needed methods to implement filtering on individual columns

      private

      # Enhance the list entries with an optional search criteria
      def list_entries
        @rq = super.ransack(params[:rq], search_key: :rq)
        @pagy, @records = pagy(@rq.result)
        @records
      end

      # Concat the word clauses with AND.
      def filter_conditions
        if filter_support? && params[:q].present?
          # search_word_conditions.reduce do |query, condition|
          #   query.and(condition)
          # end
        end
      end


      # Returns true if this controller has searchable columns.
      def filter_support?
        # search_columns.present?
        true
      end
    end

    # Class methods for Filterable.
    module ClassMethods
      def add_filter(attribute, options = {})
        self.filters << Filter.new(attribute, options)
      end
    end

  end

  class Filter
    attr_reader :attribute, :options, :method

    def initialize(attribute, options, method: nil)
      @attribute = attribute
      @options = options
      @method = method
    end

    def ransack_attribute
      # TODO: TLA 5/4/2022 - Handle strings, date ranges, numeric ranges, and boolean
      # TODO: TLA 5/4/2022 - Allow for custom values as well, like 'first_name_or_last_name_cont' or something
      "#{attribute}_cont"
    end

    # TODO: TLA 5/4/2022 - we probably don't need this method, but useful for reference for now
    def default_input_type
      if method =~ /_(eq|equals|cont|contains|start|starts_with|end|ends_with)\z/
        :string
      elsif model_class._ransackers.key?(method.to_s)
        model_class._ransackers[method.to_s].type
      elsif reflection_for(method) || polymorphic_foreign_type?(method)
        :select
      elsif column = column_for(method)
        case column.type
        when :date, :datetime
          :date_range
        when :string, :text
          :string
        when :integer, :float, :decimal
          :numeric
        when :boolean
          :boolean
        end
      end
    end

    private

    def column_for(method)
      klass.columns_hash[method.to_s] if klass.respond_to? :columns_hash
    end
  end
end


# GOAL
# Filter by column
# 1. String - free form
# 2. String - dropdown
# 3. Date range - pickers
# 4. Date/Time range - pickers
# 5. Numeric range
#
