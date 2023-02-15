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
$(document).on('turbolinks:load', function () {
  $('.select-2').select2();
  flatpickr("[data-behaviour='date-only']", {
    dateFormat: "d-m-Y"
  })
  setup_select_2_ajax()
})

setup_select_2_ajax();