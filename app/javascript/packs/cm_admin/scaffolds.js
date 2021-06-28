import flatpickr from "flatpickr";

$(document).ready(function(e) {
  $('.select-2').select2();
  flatpickr("[data-behaviour='date-only']", {})
  flatpickr("[data-behaviour='date-time']", {
    enableTime: true
  })
}
);
$("[data-behaviour='decimal-only']").on("keypress keyup blur",function (event) {
  //this.value = this.value.replace(/[^0-9\.]/g,'');
$(this).val($(this).val().replace(/[^0-9\.]/g,''));
  if ((event.which != 46 || $(this).val().indexOf('.') != -1) && (event.which < 48 || event.which > 57)) {
      event.preventDefault();
  }
});

$("[data-behaviour='integer-only']").on("keypress keyup blur",function (event) {    
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
