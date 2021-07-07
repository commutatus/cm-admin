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
$(document).on('click', '[data-behavior="filter-option"]', function(e) {
  var filter_type = $(this).data('filter-type')
  var filter_column = $(this).data('db-column')
  unhide_filter(filter_type, filter_column)
})

unhide_filter = function(filter_type, filter_column) {
  $($('[data-behaviour="filter"][data-filter-type=' + filter_type + '][data-db-column='+ filter_column + ']')[0]).parent().parent().removeClass('hidden')
};

// Only allow numeric input (both integer and decimal) values in range filters
$(document).on('keypress', '[data-behaviour="filter"][data-filter-type="range"]', function(e){
  var charCode = (e.which) ? e.which : e.keyCode
  if (charCode > 31 && (charCode != 46 &&(charCode < 48 || charCode > 57)))
    return false;
  return true;
});

$(document).on('keyup', '#cm-add-filter-search', function(e){
  var input, filter, ul, li, a, i;
  input = $(this);
  filter = input.val().toUpperCase();
  div = document.getElementById("add-filter-dropdown");
  a = div.getElementsByTagName("li");
  for (i = 0; i < a.length; i++) {
    txtValue = a[i].textContent || a[i].innerText;
    if (txtValue.toUpperCase().indexOf(filter) > -1) {
      a[i].style.display = "";
    } else {
      a[i].style.display = "none";
    }
  }
});
