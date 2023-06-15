module CsvHelper
  def csv_link(classes: [])
    link_to 'CSV', csv_url, class: classes
  end

  def csv_url
    params = request.query_parameters.except :format, :commit
    url_for(params: params, format: :csv)
  end
end
