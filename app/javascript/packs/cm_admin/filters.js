var current_request = null;

get_filtered_data = function(filter_type, filter_value, filter_columns=null) {
  var url = window.location.pathname

  // Based on the value changed for recent filter generate the filter_params hash
  var filter_params = {};
  if (filter_columns) {
    filter_params[filter_type] = {};
    filter_params[filter_type][filter_columns] = filter_value
  } else {
    filter_params[filter_type] = filter_value
  }

  // TODO add sort params in the query_string
  // page params is reinitialized to 1 when any new filter value is applied so
  // that it won't throw the error when the user doesn't have sufficent data
  // to display on the table.
  var query_string = {
    filters: filter_params,
    page: 1
  };

  // Generate the query_string by concatenating the filter_params and
  // searchParams that are already applied, if searchParams are present.
  var searchParams = window.location.search
  if (searchParams.length > 0) {
    filter_params = jQuery.param(query_string)
    var availableParams = searchParams + '&' + newParams
    query_string = getParamsAsObject(availableParams)
  }

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
}

$(document).on('change', '[data-behaviour="filter"]', function(e) {
  var filter_type = $(this).data('filter-type')
  var filter_column = $(this).data('db-column')

  if ($(this).data('filter-type') == 'date') {
    if ($(this).val().includes(' to ')){
      var filter_value = $(this).val()
    }
  } else if ($(this).data('filter-type') == 'range') {
    var rangeElements = $('[data-behaviour="filter"][data-filter-type="range"][data-db-column=' + $(this).data('db-column') + ']')
    if ($(rangeElements[0]).val().length > 0 && $(rangeElements[1]).val().length > 0) {
      var filter_value = $(rangeElements[0]).val() + ' to ' + $(rangeElements[1]).val()
    }
  } else {
    var filter_value = $(this).val()
  }

  if (filter_value.length > 0) {
    get_filtered_data(filter_type, filter_value, filter_column)
  }
});

$(document).on('keyup', '.search-input', function(e) {
  e.stopPropagation();

  var search_val = $(this).val();
  get_filtered_data('search', search_val)
});

$(document).on('click', '[data-behavior="filter-option"]', function(e) {
  var filter_type = $(this).data('filter-type')
  var filter_column = $(this).data('db-column')
  unhide_filter(filter_type, filter_column)
});

unhide_filter = function(filter_type, filter_column) {
  var filter_element = $('[data-behaviour="filter"][data-filter-type=' + filter_type + '][data-db-column='+ filter_column + ']')
  filter_element.parent().parent().removeClass('hidden')

  if (filter_type == 'date') {
    filter_element.click();
  }
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

// Method to decode the encoded nested and/or complex hash and convert it to
// object that is used for filters while sending the data to the backend.
var getParamsAsObject = function (query) {
  query = query.substring(query.indexOf('?') + 1);

  var re = /([^&=]+)=?([^&]*)/g;
  var decodeRE = /\+/g;

  var decode = function (str) {
    return decodeURIComponent(str.replace(decodeRE, " "));
  };

  var params = {}, e;
  while (e = re.exec(query)) {
    var k = decode(e[1]), v = decode(e[2]);
    if (k.substring(k.length - 2) === '[]') {
      k = k.substring(0, k.length - 2);
      (params[k] || (params[k] = [])).push(v);
    }
    else params[k] = v;
  }

  var assign = function (obj, keyPath, value) {
    var lastKeyIndex = keyPath.length - 1;
    for (var i = 0; i < lastKeyIndex; ++i) {
      var key = keyPath[i];
      if (!(key in obj))
        obj[key] = {}
      obj = obj[key];
    }
    obj[keyPath[lastKeyIndex]] = value;
  }

  for (var prop in params) {
    var structure = prop.split('[');
    if (structure.length > 1) {
      var levels = [];
      structure.forEach(function (item, i) {
        var key = item.replace(/[?[\]\\ ]/g, '');
        levels.push(key);
      });
      assign(params, levels, params[prop]);
      delete(params[prop]);
    }
  }
  return params;
};
