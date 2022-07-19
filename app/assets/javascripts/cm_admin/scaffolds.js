import jQuery from 'jquery';
window.jQuery = jQuery // <- "select2" will check this
window.$ = jQuery

import 'moment'
import 'bootstrap'
import 'flatpickr'
import 'jgrowl'
jqueryJgrowl()
import Select2 from "select2"
Select2()

// import '@nathanvda/cocoon'
import 'daterangepicker'
import '@fortawesome/fontawesome-free'
import jqueryJgrowl from 'jgrowl';


flatpickr("[data-behaviour='date-only']", {
  dateFormat: "d-m-Y"
})
flatpickr("[data-behaviour='date-time']", {
  enableTime: true
})
flatpickr("[data-behaviour='filter'][data-filter-type='date']", {
  mode: 'range'
})
$('.select-2').select2();
console.log("Outside turbolinks")
$(document).on('turbolinks:load', function () {
  console.log("Came inside turbolinks")
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