$(document).on('turbolinks:load', function () {
  $('.select-2').select2();
  flatpickr("[data-behaviour='date-only']", {
    dateFormat: "d-m-Y"
  })
  flatpickr("[data-behaviour='date-time']", {
    enableTime: true
  })
  flatpickr("[data-behaviour='filter'][data-filter-type='date']", {
    mode: 'range'
  })
  var el = document.getElementsByClassName('columns-list')
  if(el[0]) {
    Sortable.create(el[0],{
      handle: '.dragger',
      animation: 150
    });
  }
  var headerElemHeight = $('.page-top-bar').height() + 64
  var calculatedHeight = "calc(100vh - " + headerElemHeight+"px"+")"
  $('.new-admin-table').css("maxHeight", calculatedHeight);
});

$(document).on("keypress keyup blur", "[data-behaviour='decimal-only'], [data-behaviour='filter'][data-filter-type='range']", function (e) {
  var charCode = (e.which) ? e.which : e.keyCode
  if (charCode > 31 && (charCode != 46 &&(charCode < 48 || charCode > 57)))
    return false;
  return true;
});

$(document).on("keypress keyup blur", "[data-behaviour='integer-only']", function (event) {
 $(this).val($(this).val().replace(/[^\d].+/, ""));
  if ((event.which < 48 || event.which > 57)) {
      event.preventDefault();
  }
});

$(document).on('click', '.row-action-cell', function(e) {
  e.stopPropagation();
  if ($(this).hasClass('opacity-1')) {
    $('.row-action-cell').removeClass('opacity-1')
  } else {
    $('.row-action-cell').removeClass('opacity-1')
    $(this).addClass('opacity-1');
  }
  if ($(this).find('.table-export-popup').hasClass('hidden')) {
    return $(this).find('.table-export-popup').removeClass('hidden');
  } else {
    return $(this).find('.table-export-popup').addClass('hidden');
  }
});


$(document).on('click', '.drawer-btn', function(e) {
  e.stopPropagation();
  drawer_el = $(this).parent().closest('.drawer').find('.cm-drawer')
  if (drawer_el.hasClass('hidden')) {
     drawer_el.removeClass('hidden');
     drawer_container = drawer_el.find('.drawer-container')
     if (drawer_container.hasClass('drawer-slide-out')) {
        drawer_container.removeClass('drawer-slide-out');
     }
     drawer_container.addClass('drawer-slide-in');
  } else {
    return drawer_el.addClass('hidden');
  }
});

$(document).on('click', '.drawer-close', function(e) {
  e.stopPropagation();
  $('.drawer-container').removeClass('drawer-slide-in');
  $('.drawer-container').addClass('drawer-slide-out');
  setTimeout(() => {
    $('.cm-drawer').addClass('hidden');
  }, 300);
});

$(document).on('change', '.linked-field-request', function(e) {
  e.stopPropagation();
  request_url = $(this).data('target-url').replace(':param_1', $(this).val())
  $.ajax(request_url, {
    type: 'GET',
    success: function(data) {
      apply_response_to_field(data)
    },
    error: function(jqxhr, textStatus, errorThrown) {
      console.log(errorThrown, textStatus);
    }
  });
});

function apply_response_to_field(response) {
  console.log(response['fields'])
  $.each(response['fields'], function(key, value) {
    if (value['target_type'] == 'select') {
      update_options_in_select(value['target_value'])
    }
    else if (value['target_type'] == 'input') {
      update_options_input_value(value['target_value'])
    }
  })
}

function update_options_input_value(field_obj) {
  console.log("====================")
  console.log("field_obj", field_obj)
  input_tag = $('#' + field_obj['table'] + '_' + field_obj['field_name'])
  input_tag.val(field_obj['field_value'])
}

function update_options_in_select(options) {
  console.log("=====================")
  console.log(options)
  select_tag = $('#' + options['table'] + '_' + options['field_name'])
  select_tag.empty();
  console.log(options['field_value'])
  $.each(options['field_value'], function(key, value) {
    select_tag.append($("<option></option>")
      .attr("value", value[1]).text(value[0]));
  });
}

$(document).on('cocoon:after-insert', '.nested-field-wrapper', function(e) {
  e.stopPropagation();
  replaceAccordionTitle($(this))
});

$(document).on('cocoon:after-remove', '.nested-field-wrapper', function(e) {
  e.stopPropagation();
  replaceAccordionTitle($(this))
});

$(document).ready( function () {
  $('.nested-field-wrapper').each(function() {
    replaceAccordionTitle($(this))
  })
});

var replaceAccordionTitle = function(element) {
  var i = 0;
  var table_name = $(element).data('table-name')
  var model_name = $(element).data('model-name')
  $(element).find('.accordion-item:visible').each(function() {
    i++;
    var accordion_title = model_name + ' ' + i
    var accordion_id = table_name + '-' + i
    $(this).find('.accordion-button').text(accordion_title);
    $(this).find('.accordion-button').attr('data-bs-target', '#' + accordion_id);
    $(this).find('.accordion-collapse').attr('id', accordion_id);
  });
}