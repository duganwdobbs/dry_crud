module DryCrud
  # This is adapted from ActiveAdmin::CSVBuilder
  module Csv
    # Csv::Builder stores CSV configuration
    #
    # Usage example:
    #
    #   csv_builder = Csv::Builder.new
    #   csv_builder.column :id
    #   csv_builder.column("Name") { |resource| resource.full_name }
    #   csv_builder.column(:name, humanize_name: false)
    #   csv_builder.column("name", humanize_name: false) { |resource| resource.full_name }
    #
    #   csv_builder = Csv::Builder.new col_sep: ";"
    #   csv_builder = Csv::Builder.new humanize_name: false
    #   csv_builder.column :id
    #
    #
    class Builder
      include UtilityHelper

      # Return a default Csv::Builder for a controller
      # The Csv::Builder's columns would be Id followed by this
      # controller's crud_attrs
      def self.default_for_controller(controller)
        new controller: controller do
          column :id
          default_crud_attrs.each { |c| column c }
        end
      end

      attr_reader :columns, :options, :view_context

      COLUMN_TRANSITIVE_OPTIONS = [:humanize_name].freeze
      DEFAULT_OPTIONS = { col_sep: ",", byte_order_mark: "\xEF\xBB\xBF" }.freeze

      def initialize(options = {}, &block)
        @controller = options.delete(:controller)
        @columns = []
        @options = DEFAULT_OPTIONS.merge options
        @block = block
      end

      def column(name, options = {}, &block)
        @columns << Column.new(name, @controller, column_transitive_options.merge(options), block)
      end

      def build(controller, csv)
        collection = controller.list_entries
        columns = exec_columns controller.view_context
        bom = options.delete :byte_order_mark
        column_names = options.delete(:column_names) { true }
        csv_options = options.except :encoding_options, :humanize_name

        csv << bom if bom

        if column_names
          csv << CSV.generate_line(columns.map { |c| encode c.name, options }, **csv_options)
        end

        ActiveRecord::Base.uncached do
          collection.each do |resource|
            csv << CSV.generate_line(build_row(resource, columns, options), **csv_options)
          end
        end

        csv
      end

      def exec_columns(view_context = nil)
        @view_context = view_context
        @columns = [] # we want to re-render these every instance
        instance_exec &@block if @block.present?
        columns
      end

      def build_row(resource, columns, options)
        columns.map do |column|
          encode call_method_or_proc_on(resource, column.data), options
        end
      end

      def encode(content, options)
        if options[:encoding]
          if options[:encoding_options]
            content.to_s.encode options[:encoding], **options[:encoding_options]
          else
            content.to_s.encode options[:encoding]
          end
        else
          content
        end
      end

      def method_missing(method, *args, &block)
        if @view_context.respond_to? method
          @view_context.public_send method, *args, &block
        else
          super
        end
      end

      class Column
        include FormatHelper

        attr_reader :name, :data, :options

        DEFAULT_OPTIONS = { humanize_name: true }

        def initialize(name, controller = nil, options = {}, block = nil)
          @options = options.reverse_merge(DEFAULT_OPTIONS)
          @name = humanize_name(name, controller, @options[:humanize_name])
          @data = block || name.to_sym
        end

        def humanize_name(name, controller, humanize_name_option)
          if humanize_name_option
            name.is_a?(Symbol) && controller ? captionize(name, controller.class) : name.to_s.humanize
          else
            name.to_s
          end
        end
      end

      private

      def column_transitive_options
        @column_transitive_options ||= @options.slice(*COLUMN_TRANSITIVE_OPTIONS)
      end


      # Call a method on an object or instance_exec a proc passing in the object as
      # the first parameter.
      #
      # Calling with a String or Symbol:
      #
      #     call_method_or_proc_on(@my_obj, :size) same as @my_obj.size
      #
      # Calling with a Proc:
      #
      #     proc = Proc.new{|s| s.size }
      #     call_method_or_proc_on(@my_obj, proc)
      #
      # By default, the Proc will be instance_exec'd within self. If you would rather
      # not instance exec, but just call the Proc, then pass along `exec: false` in
      # the options hash.
      #
      #     proc = Proc.new{|s| s.size }
      #     call_method_or_proc_on(@my_obj, proc, exec: false)
      #
      # You can pass along any necessary arguments to the method / Proc as arguments. For
      # example:
      #
      #     call_method_or_proc_on(@my_obj, :find, 1) #=> @my_obj.find(1)
      #
      def call_method_or_proc_on(receiver, *args)
        options = { exec: true }.merge(args.extract_options!)

        symbol_or_proc = args.shift

        case symbol_or_proc
        when Symbol, String
          receiver.public_send symbol_or_proc.to_sym, *args
        when Proc
          if options[:exec]
            instance_exec(receiver, *args, &symbol_or_proc)
          else
            symbol_or_proc.call(receiver, *args)
          end
        else
          symbol_or_proc
        end
      end
    end
  end
end
