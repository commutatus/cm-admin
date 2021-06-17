var current_request = null;

$(document).on('keyup', '.search-input', function(e) {
  e.stopPropagation();
  var url = window.location.pathname
  var search_val = $(this).val();
  var filter_params = {};
  if (search_val) {
    filter_params['search'] = search_val
  }
  // TODO add page and sort params in the query_string
  query_string = {
    filters: filter_params
  };
  return current_request = $.ajax(url, {
    type: 'GET',
    data: query_string,
    beforeSend: function() {
      if (current_request !== null) {
        current_request.abort();
      }
    },
    success: function(data) {
      var queryParam = jQuery.param(query_string)
      window.history.pushState("", "", url + '?' + queryParam);
      $('.index-page__table-container').html(data);
    },
    error: function(jqxhr, textStatus, errorThrown) {
      console.log(errorThrown, textStatus);
    }
  });
});
