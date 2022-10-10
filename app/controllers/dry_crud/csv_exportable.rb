require "csv"

module DryCrud

  # The CSV Export functionality for the index table.
  module CsvExportable
    extend ActiveSupport::Concern

    included do
      class_attribute :csv_builder
      self.csv_builder = nil

      prepend Prepends
    end

    # Class methods for CsvExportable.
    class_methods do
      # Configure the Csv format
      #
      # For example:
      #
      #   csv do
      #     column :name
      #     column("Author") { |post| post.author.full_name }
      #   end
      #
      #   csv col_sep: ";", force_quotes: true do
      #     column :name
      #   end
      #
      def csv(options = {}, &block)
        options[:controller] = self

        self.csv_builder = Csv::Builder.new(options, &block)
      end
    end

    module Prepends
      def index
        super

        respond_to do |format|
          format.csv { stream_csv }
          format.html
        end
      end
    end

    protected

    def stream_resource(&block)
      headers["X-Accel-Buffering"] = "no"
      headers["Cache-Control"] = "no-cache"
      headers["Last-Modified"] = Time.current.httpdate

      self.response_body = Enumerator.new &block
    end

    def csv_filename
      "#{model_identifier.to_s.gsub('_', '-')}-#{Time.zone.now.to_date.to_s(:default)}.csv"
    end

    def stream_csv
      self.csv_builder ||= Csv::Builder.default_for_controller(self)

      headers["Content-Type"] = "text/csv; charset=utf-8"
      headers["Content-Disposition"] = %{attachment; filename="#{csv_filename}"}
      stream_resource &csv_builder.method(:build).to_proc.curry[self]
    end
  end
end
