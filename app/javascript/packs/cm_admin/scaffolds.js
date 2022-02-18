$(document).ready(function(e) {
  $('.select-2').select2();
  flatpickr("[data-behaviour='date-only']", {})
  flatpickr("[data-behaviour='date-time']", {
    enableTime: true
  })
  flatpickr("[data-behaviour='filter'][data-filter-type='date']", {
    mode: 'range'
  })
  Sortable.create($('.columns-list')[0],{
    handle: '.dragger',
    animation: 150
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
  if ($('.cm-drawer').hasClass('hidden')) {
     $('.cm-drawer').removeClass('hidden');
     if ($('#drawer-container').hasClass('drawer-slide-out')) {
        $('#drawer-container').removeClass('drawer-slide-out');
     }
     $('#drawer-container').addClass('drawer-slide-in');
  } else {
    return $('.cm-drawer').addClass('hidden');
  }
});

$(document).on('click', '.drawer-close', function(e) {
  e.stopPropagation();
  $('#drawer-container').removeClass('drawer-slide-in');
  $('#drawer-container').addClass('drawer-slide-out');
  setTimeout(() => {
    $('.cm-drawer').addClass('hidden');
  }, 300);
});