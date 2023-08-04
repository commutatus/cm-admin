$(document).on('click', '[data-behaviour="bulk-action-checkbox"]', function(e) {
  if ($('[data-behaviour="bulk-action-checkbox"]').is(':checked')) {
    $('[data-section="bulk-action"]').removeClass('hidden')
    setBulkActionParams()
  } else {
    $('[data-section="bulk-action"]').addClass('hidden')
  }
});

$(document).on('click', '[data-behaviour="bulk-action-select-all"]', function(e) {
  if ($(this).is(':checked')) {
    $('[data-behaviour="bulk-action-checkbox"]').prop('checked', true)
    $('[data-section="bulk-action"]').removeClass('hidden')
    setBulkActionParams()
  } else {
    $('[data-behaviour="bulk-action-checkbox"]').prop('checked', false)
    $('[data-section="bulk-action"]').addClass('hidden')
  }
});

function setBulkActionParams() {
  var selected_ids = []
  $('[data-behaviour="bulk-action-checkbox"]:checked').each(function(){ selected_ids.push($(this).data('ar-object-id')) })
  var bulk_action_form = '[data-section="bulk-action"] form'
  if ($(bulk_action_form)) {
    if ($(bulk_action_form + ' [name="selected_ids"]').length == 0) {
      $('<input>').attr({
        type: 'hidden',
        name: 'selected_ids'
      }).appendTo(bulk_action_form);
    }
  }
  $('[data-section="bulk-action"] [name="selected_ids"]').each(function( i ) {
    $(this).val(selected_ids)
  })
}