module CsvHelper
  def csv_link(classes: [])
    params = request.query_parameters.except :format, :commit
    link_to 'CSV', url_for(params: params, format: :csv), class: classes
  end
end
