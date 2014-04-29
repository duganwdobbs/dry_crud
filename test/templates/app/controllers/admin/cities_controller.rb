# encoding: UTF-8

module Admin
  # Cities Controller nested under /admin and countries
  class CitiesController < AjaxController

    self.nesting = :admin, Country

    self.search_columns = :name, 'countries.name'

    self.default_sort = 'countries.code, cities.name'

    if respond_to?(:permitted_attrs)
      self.permitted_attrs = [:name, :person_ids]
    end

    private

    def list_entries
      list = super.includes(:country)
      list = list.references(:countries) if list.respond_to?(:references)
      list
    end

  end
end
