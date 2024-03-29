import jQuery from 'jquery';
window.jQuery = jQuery // <- "select2" will check this
window.$ = jQuery

// This is a hack to fix 'process is not defined'
// Ref article: https://adambien.blog/roller/abien/entry/uncaught_referenceerror_process_is_not
// Based on this filter dropdown works.
window.process = {
  env: {
      NODE_ENV: 'development'
  }
} 

import 'moment'
import 'bootstrap'
import '@popperjs/core'
import 'flatpickr'
import 'jgrowl'
import Select2 from "select2"
Select2()

// import '@nathanvda/cocoon'
import 'daterangepicker'
import '@fortawesome/fontawesome-free'
import jqueryJgrowl from 'jgrowl';


document.addEventListener("turbo:load", function () {
  flatpickr("[data-behaviour='date-only']", {
    dateFormat: "d-m-Y"
  })
  flatpickr("[data-behaviour='date-time']", {
    enableTime: true
  })
  flatpickr("[data-behaviour='filter'][data-filter-type='date']", {
    mode: 'range'
  })
  $('.select-2').select2({
    theme: "bootstrap-5",
  });
  jqueryJgrowl()
  setup_select_2_ajax();
});

$(document).on('click', '.menu-item', function(e) {
  $('.profile-popup').toggleClass('hidden');
});

$(document).on('click', '.destroy-attachment', function(e) {
  var ar_id = $(this).data('ar-id')
  $(this).addClass('hidden')
  $(this).append('<input type="text" name="attachment_destroy_ids[]" value="' + ar_id + '"/>')
})

window.addEventListener('popstate', e => window.location.reload() );

function setup_select_2_ajax(){
  $(".select-2-ajax").each(function(index, element){
    $(element).select2({
      ajax: {
        url: $(element)[0]['dataset'].ajaxUrl,
        dataType: 'json',
        processResults: (data, params) => {
          return {
            results: data.results,
          }
        },
      },
      minimumInputLength: 0
    });
  });
}