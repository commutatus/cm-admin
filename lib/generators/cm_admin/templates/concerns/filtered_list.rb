class FilteredList
  attr_reader :data, :facets, :paging

  def initialize(paginated_list)
    self.data   = paginated_list[:list]
    self.paging = paginated_list
  end

  def data=(data)
    @data = []
    @data = data if data.present?
  end

  def paging=(paginated_list)
    @paging = {
      total_items:  paginated_list[:list].total_count,
      current_page: paginated_list[:list].current_page,
      total_pages:  paginated_list[:list].total_pages,
      total_count:  paginated_list[:total_count]
    }
  end
end