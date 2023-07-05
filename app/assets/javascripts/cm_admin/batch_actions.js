$(document).on('click', '[data-behaviour="bulk-checkbox"]', function(e) {
  if ($('[data-behaviour="bulk-checkbox"]').is(':checked')) {
    $('[data-section="batch-action"]').removeClass('hidden')
    setBatchActionParams()
  } else {
    $('[data-section="batch-action"]').addClass('hidden')
  }
});

$(document).on('click', '[data-behaviour="select-all-checkbox"]', function(e) {
  if ($(this).is(':checked')) {
    $('[data-behaviour="bulk-checkbox"]').prop('checked', true)
    $('[data-section="batch-action"]').removeClass('hidden')
    setBatchActionParams()
  } else {
    $('[data-behaviour="bulk-checkbox"]').prop('checked', false)
    $('[data-section="batch-action"]').addClass('hidden')
  }
});

function setBatchActionParams() {
  var selected_ids = []
  $('[data-behaviour="bulk-checkbox"]:checked').each(function(){ selected_ids.push($(this).data('object-id')) })
  $('[data-section="batch-action"] [name="selected_ids"]').each(function( i ) {
    $(this).val(selected_ids)
  })
}