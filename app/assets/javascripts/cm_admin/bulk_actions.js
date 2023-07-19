$(document).on('click', '[data-behaviour="bulk-checkbox"]', function(e) {
  if ($('[data-behaviour="bulk-checkbox"]').is(':checked')) {
    $('[data-section="bulk-action"]').removeClass('hidden')
    setBulkActionParams()
  } else {
    $('[data-section="bulk-action"]').addClass('hidden')
  }
});

$(document).on('click', '[data-behaviour="select-all-checkbox"]', function(e) {
  if ($(this).is(':checked')) {
    $('[data-behaviour="bulk-checkbox"]').prop('checked', true)
    $('[data-section="bulk-action"]').removeClass('hidden')
    setBulkActionParams()
  } else {
    $('[data-behaviour="bulk-checkbox"]').prop('checked', false)
    $('[data-section="bulk-action"]').addClass('hidden')
  }
});

function setBulkActionParams() {
  var selected_ids = []
  $('[data-behaviour="bulk-checkbox"]:checked').each(function(){ selected_ids.push($(this).data('object-id')) })
  $('[data-section="bulk-action"] [name="selected_ids"]').each(function( i ) {
    $(this).val(selected_ids)
  })
}