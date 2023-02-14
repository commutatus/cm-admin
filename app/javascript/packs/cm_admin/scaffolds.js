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

  $(".select-2-ajax").each(function(index, element){
    $(element).select2({
      ajax: {
        url: $(element)[0]['dataset'].ajaxUrl,
        dataType: 'json',
        processResults: (data, params) => {
          const results = data.items.map(item => {
            return {
              id: item.id,
              text: item.text,
            };
          });
          return {
            results: results,
          }
        },
      },
      minimumInputLength: 1
    });
  });
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

$(document).on('change', '[data-field-type="linked-field"]', function(e) {
  e.stopPropagation();
  params = {}
  params[$(this).data('field-name')] = $(this).val()
  request_url = $(this).data('target-url') + '?' + $.param(params);
  console.log(request_url)
  $.ajax(request_url, {
    type: 'GET',
    success: function(data) {
      apply_response_to_field(data)
    },
    error: function(jqxhr, textStatus, errorThrown) {
      alert('Something went wrong. Please try again later.\n' + errorThrown);
    }
  });
});

function apply_response_to_field(response) {
  $.each(response['fields'], function(key, value) {
    switch(value['target_type']) {
      case 'select':
        update_options_in_select(value['target_value'])
        break;
      case 'input':
        update_options_input_value(value['target_value'])
        break;
      case 'toggle_visibility':
        toggle_field_visibility(value['target_value'])
    }
  })
}

function update_options_input_value(field_obj) {
  input_tag = $('#' + field_obj['table'] + '_' + field_obj['field_name'])
  input_tag.val(field_obj['field_value'])
}

function update_options_in_select(field_obj) {
  select_tag = $('#' + field_obj['table'] + '_' + field_obj['field_name'])
  select_tag.empty();
  $.each(field_obj['field_value'], function(key, value) {
    select_tag.append($("<option></option>")
      .attr("value", value[1]).text(value[0]));
  });
}

function toggle_field_visibility(field_obj) {
  element = $('#' + field_obj['table'] + '_' + field_obj['field_name'])
  element.closest('.input-wrapper').toggleClass('hidden')
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