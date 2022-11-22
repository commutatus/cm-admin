var currentRequest = null;

// Main method which will structure the existing filter values with the newly
// applied filter. Send and receive the value from the backend.
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
    // Delete the previous applied value for multi_select filter from the
    // searchParams as altering the array with new and old value will create
    // more complicated logic. The new value is passed and structured in
    // filterParams and will be concadinated with the searchParams post deletion
    if (filterType == 'multi_select') {
      searchParams = getParamsAsObject(searchParams)
      if (searchParams['filters'][filterType] != undefined) {
        delete(searchParams['filters'][filterType][filterColumn])
      }
      searchParams = jQuery.param(searchParams)
    }
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
      $('.cm-index-page__table-container').html(data);
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
    var rangeElements = $(this).parent().children()
    var filterValue = $(rangeElements[0]).val() + ' to ' + $(rangeElements[1]).val()
  } else {
    var filterValue = $(this).val()
  }

  $(this).parents(':nth(1)').children(':first').children(':nth(1)').text(filterValue)
  $(this).parents(':nth(1)').children(':first').children(':last').removeClass('hidden')

  unhideClearFilterBtn(filterValue)
  getFilteredData(filterType, filterValue, filterColumn)
});

$(document).on('keyup', '[data-behaviour="input-search"]', function(e) {
  e.stopPropagation();

  var searchValue = $(this).val();
  unhideClearFilterBtn(searchValue)
  getFilteredData('search', searchValue)
});

$(document).on('click', '[data-behaviour="filter-option"]', function(e) {
  var filterType = $(this).data('filter-type')
  var filterColumn = $(this).data('db-column')

  // Clear the search value post selection and regenerate the dropdown elements.
  var searchInputElement = $(this).parents(':nth(1)').children(':first').children()
  searchInputElement.val('')
  CmFilter.dropdown_search(searchInputElement)

  unhideFilter(filterType, filterColumn)
});

var unhideFilter = function(filterType, filterColumn) {
  var filterInputElement = $('[data-behaviour="filter-input"][data-filter-type=' + filterType + '][data-db-column='+ filterColumn + ']')

  filterInputElement.parent().removeClass('hidden');
  filterInputElement.click()
};

// Search inside the dropdowns
$(document).on('keyup', '[data-behaviour="dropdown-filter-search"]', function(e) {
  CmFilter.dropdown_search($(this))
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
  } else if (filterType == 'multi_select') {
    $(this).parent().children(':last').toggleClass('hidden')
  } else if (filterType == 'date') {
    filterElement.click()
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

// Selecting options for single and multi select filters
$(document).on('click', '[data-behaviour="select-option"]', function(e) {
  var filterType = $(this).data('filter-type')
  var filterColumn = $(this).data('db-column')

  if (filterType == 'single_select') {
    var filterValue = $(this).data('value')
    var filterText = $(this).text()
    if (!this.classList.contains('selected')) {
      if (this.parentNode.querySelector('.list-item.selected') != null) {
        this.parentNode.querySelector('.list-item.selected').classList.remove('selected');
      }
      $(this).addClass('selected')
    }

    $(this).parents(':nth(4)').children(':first').children(':nth(1)').text(filterText)
    $(this).parents(':nth(4)').children(':first').children(':last').removeClass('hidden')

    // Clear the search value post selection and regenerate the dropdown elements.
    var searchInputElement = $(this).parents(':nth(1)').children(':first').children()
    searchInputElement.val('')
    CmFilter.dropdown_search(searchInputElement)

    unhideClearFilterBtn(filterValue)
    getFilteredData(filterType, filterValue, filterColumn)
  }
  else if (filterType == 'multi_select') {
    var parentChip = $(this).parent().siblings(':first')
    var checkboxElement = $(this).find('.cm-checkbox')
    checkboxElement.prop('checked', !checkboxElement.prop('checked'))
    var checkedCount = $(this).parent().find('.cm-checkbox').filter(':checked').length
    if (checkboxElement.prop('checked')) {
      var chip = $('<div class="chip"></div>')
      var firstSpan = $('<span></span>').text($(this).text())
      var secondSpan = $('<span data-behaviour="selected-chip"><i class="fa fa-times"></i></span>')
      parentChip.prepend(chip.append(firstSpan).append(secondSpan))
    } else {
      var chipElement = parentChip.find('.chip')
      for(var i = 0; i < chipElement.length; i++) {
        if ($(chipElement[i]).text() == $(this).text()) {
          $(chipElement[i]).remove()
          break
        }
      }
    }

    if (checkedCount > 0) {
      parentChip.addClass('search-with-chips').removeClass('search-area')
      $(this).parents(':nth(1)').children(':last').addClass('active')
    } else {
      parentChip.addClass('search-area').removeClass('search-with-chips')
      $(this).parents(':nth(1)').children(':last').removeClass('active')
    }
  }
});

// Apply button for multi select filters
$(document).on('click', '.apply-area', function(e) {
  var filterInputElement = $(this).parents(':nth(3)').children(':first')
  var filterType = filterInputElement.data('filter-type')
  var filterColumn = filterInputElement.data('db-column')
  var filterValue = []
  var filterValueText = []

  var selectFilterElement = $('[data-behaviour="select-option"][data-filter-type=' + filterType + '][data-db-column=' + filterColumn + ']')
  var checkedElements = selectFilterElement.find('.cm-checkbox').filter(':checked')

  if (checkedElements.length > 0) {
    for(var i = 0; i < checkedElements.length; i++) {
      filterValue.push($(checkedElements[i]).parent().data('value'))
      filterValueText.push($(checkedElements[i]).parent().text())
    }

    truncatedFilterValue = filterValueText[0]
    if (filterValue.length > 1) {
      truncatedFilterValue += ' + ' + (filterValue.length - 1) + ' more'
    }

    filterInputElement.children(':nth(1)').text(truncatedFilterValue)
    filterInputElement.children(':last').removeClass('hidden')
    selectFilterElement.parents(':nth(3)').addClass('hidden')

    // Clear the search value post selection and regenerate the dropdown elements.
    var searchInputElement = $(this).parent().children(':first').children(':last')
    searchInputElement.val('')
    CmFilter.dropdown_search(searchInputElement)

    unhideClearFilterBtn(filterValue)
    getFilteredData(filterType, filterValue, filterColumn)
  }
});

// Remove single applied filter.
$(document).on('click', '.filter-chip-remove', function(e) {
  var url = window.location.pathname
  var filterType = $(this).parent().data('filter-type')
  var filterColumn = $(this).parent().data('db-column')

  var searchParams = window.location.search
  if (searchParams.length > 0) {
    queryString = getParamsAsObject(searchParams)
    if (queryString['filters'][filterType] != undefined) {
      delete(queryString['filters'][filterType][filterColumn])
      var queryParam = jQuery.param(queryString)
      window.history.pushState("", "", url + '?' + queryParam);
      window.location.reload()
    }
  }
});

$(document).on('click', '[data-behaviour="selected-chip"]', function(e) {
  var filterType = $(this).parents(':nth(5)').find('.filter-chip').data('filter-type')
  var filterColumn = $(this).parents(':nth(5)').find('.filter-chip').data('db-column')
  var filterValue = $(this).siblings().text()

  var selectElement = $('[data-behaviour="select-option"][data-filter-type=' + filterType + '][data-db-column=' + filterColumn + ']')
  $(this).parent().remove()

  for(var i = 0; i < selectElement.length; i++) {
    if ($(selectElement[i]).data('value') == filterValue) {
      var checkboxElement = $(selectElement[i]).find('.cm-checkbox')
      checkboxElement.prop('checked', !checkboxElement.prop('checked'))
      break
    }
  }

  var checkedCount = $(selectElement).find('.cm-checkbox').filter(':checked').length
  if (checkedCount < 1) {
    $(selectElement).parent().siblings(':first').addClass('search-area').removeClass('search-with-chips')
    $(selectElement).parent().siblings(':last').removeClass('active')
  }
})

CmFilter = {
  // Generate or remove elements of the dropdown based on the search value.
  dropdown_search: function(element) {
    var filter = element.val().toUpperCase();
    var dropdownElements = element.parents(':nth(1)').find('.list-area').children();
    for (var i = 0; i < dropdownElements.length; i++) {
      txtValue = $(dropdownElements[i]).children().text();
      if (txtValue.toUpperCase().indexOf(filter) > -1) {
        $(dropdownElements[i]).css('display', 'flex');
      } else {
        $(dropdownElements[i]).css('display', 'none');
      }
    }
  },
  quick_input_search: function(element) {
    var filter = element.val().toUpperCase();
    var searchElements = element.parents(':nth(3)').find('.list-area').children();
    searchElements.removeClass('visible').addClass('hidden')
    for (var i = 0; i < searchElements.length; i++) {
      txtValue = $(searchElements[i]).children().text();
      if (txtValue.toUpperCase().indexOf(filter) > -1) {
        $(searchElements[i]).removeClass('hidden').addClass('visible');
      }
    }
  }
}