require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("stylesheets/cm_admin/application")
require("jquery")
require("moment")
require("bootstrap")
require('flatpickr')
require("jgrowl")
require("trix")
require('./scaffolds.js')
require('./form_validation.js')
require('./quick_search.js')
require('./filters.js')
require('./exports.js')

import jQuery from 'jquery'
import LocalTime from "local-time"
window.$ = jQuery
window.jQuery = jQuery

LocalTime.start()
require("@nathanvda/cocoon")
import "@fortawesome/fontawesome-free/css/all"
import "daterangepicker"



