var currentRequest = null;

var getFilteredData = function(filterType, filterValue, filterColumn=null) {
  var url = window.location.pathname

  // Based on the value changed for recent filter generate the filterParams hash
  var filterParams = {};
  if (filterColumn) {
    filterParams[filterType] = {};
    filterParams[filterType][filterColumn] = filterValue
  } else {
    filterParams[filterType] = filterValue
  }

  // TODO add sort params in the queryString
  // page params is reinitialized to 1 when any new filter value is applied so
  // that it won't throw the error when the user doesn't have sufficent data
  // to display on the table.
  var queryString = {
    filters: filterParams,
    page: 1
  };

  // Generate the queryString by concatenating the filterParams and
  // searchParams that are already applied, if searchParams are present.
  var searchParams = window.location.search
  if (searchParams.length > 0) {
    filterParams = jQuery.param(queryString)
    var availableParams = searchParams + '&' + filterParams
    queryString = getParamsAsObject(availableParams)
  }

  return currentRequest = $.ajax(url, {
    type: 'GET',
    data: queryString,
    beforeSend: function() {
      if (currentRequest !== null) {
        currentRequest.abort();
      }
    },
    success: function(data) {
      var queryParam = jQuery.param(queryString)
      window.history.pushState("", "", url + '?' + queryParam);
      $('.index-page__table-container').html(data);
    },
    error: function(jqxhr, textStatus, errorThrown) {
      console.log(errorThrown, textStatus);
    }
  });
}

$(document).on('change', '[data-behaviour="filter"]', function(e) {
  var filterType = $(this).data('filter-type')
  var filterColumn = $(this).data('db-column')

  if (filterType == 'range') {
    var rangeElements = $('[data-behaviour="filter"][data-filter-type="range"][data-db-column=' + filterColumn + ']')
    if ($(rangeElements[0]).val().length > 0 && $(rangeElements[1]).val().length > 0) {
      var filterValue = $(rangeElements[0]).val() + ' to ' + $(rangeElements[1]).val()
    }
  } else {
    var filterValue = $(this).val()
  }

  $($('[data-behaviour="filter-input"][data-filter-type=' + filterType + '][data-db-column=' + filterColumn + ']').children()[1]).text(filterValue)
  unhideClearFilterBtn(filterValue)
  getFilteredData(filterType, filterValue, filterColumn)
});

$(document).on('keyup', '.search-input', function(e) {
  e.stopPropagation();

  var searchValue = $(this).val();
  unhideClearFilterBtn(searchValue)
  getFilteredData('search', searchValue)
});

$(document).on('click', '[data-behavior="filter-option"]', function(e) {
  var filterType = $(this).data('filter-type')
  var filterColumn = $(this).data('db-column')
  unhideFilter(filterType, filterColumn)
});

var unhideFilter = function(filterType, filterColumn) {
  var filterElement = $('[data-behaviour="filter"][data-filter-type=' + filterType + '][data-db-column='+ filterColumn + ']')
  filterElement.parent().parent().removeClass('hidden');

  if (filterType == 'date') {
    filterElement.click();
  } else if (filterType == 'range') {
    filterElement.parent().removeClass('hidden');
  } else if (filterType == 'single_select') {
    var selectFilterElement = $('[data-behaviour="filter-input"][data-filter-type=' + filterType + '][data-db-column='+ filterColumn + ']')
    selectFilterElement.parent().removeClass('hidden');
    selectFilterElement.click()
  }
};

// Only allow numeric input (both integer and decimal) values in range filters
$(document).on('keypress', '[data-behaviour="filter"][data-filter-type="range"]', function(e){
  var charCode = (e.which) ? e.which : e.keyCode
  if (charCode > 31 && (charCode != 46 &&(charCode < 48 || charCode > 57)))
    return false;
  return true;
});

// Search inside the `+ Add filter` dropdown
$(document).on('keyup', '#cm-add-filter-search', function(e){
  var input, filter, ul, li, a, i;
  input = $(this);
  filter = input.val().toUpperCase();
  div = document.getElementById('add-filter-dropdown');
  a = div.getElementsByTagName('span');
  for (i = 0; i < a.length; i++) {
    txtValue = a[i].textContent || a[i].innerText;
    if (txtValue.toUpperCase().indexOf(filter) > -1) {
      $(a[i]).parent()[0].style.display = '';
    } else {
      $(a[i]).parent()[0].style.display = 'none';
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

$(document).on('click', '[data-behaviour="filter-input"]', function(e) {
  var filterType = $(this).data('filter-type')
  var filterColumn = $(this).data('db-column')

  var filterElement = $('[data-behaviour="filter"][data-filter-type=' + filterType + '][data-db-column=' + filterColumn +']')
  if (filterType == 'range') {
    filterElement.parent().toggleClass('hidden')
  }
})

// Remove all the applied filters and reload the page
$(document).on('click', '.clear-btn', function(e) {
  window.location.href = window.location.href.split("?")[0]
})

var unhideClearFilterBtn = function(filterValue) {
  if (filterValue) {
    $('.clear-btn').removeClass('hidden')
  }
}

$(document).on('click', '[data-behaviour="select-option"]', function(e) {
  var filterType = $(this).data('filter-type')
  var filterColumn = $(this).data('db-column')
  var filterValue = $(this).data('value')

  if (!this.classList.contains('selected')) {
    if (this.parentNode.querySelector('.list-item.selected') != null) {
      this.parentNode.querySelector('.list-item.selected').classList.remove('selected');
    }
    $(this).addClass('selected')
  }
  $($('[data-behaviour="filter-input"][data-filter-type=' + filterType + '][data-db-column=' + filterColumn + ']').children()[1]).text(filterValue)

  unhideClearFilterBtn(filterValue)
  getFilteredData(filterType, filterValue, filterColumn)
});

