$(document).on('click', '[data-behaviour="bulk-checbox"]', function(e) {
  if ($('[data-behaviour="bulk-checbox"]').is(':checked')) {
    $('.batch_actions').removeClass('hidden')
    setBatchActionParams()
  } else {
    $('.batch_actions').addClass('hidden')
  }
});

$(document).on('click', '[data-behaviour="select-all-checbox"]', function(e) {
  if ($(this).is(':checked')) {
    $('[data-behaviour="bulk-checbox"]').prop('checked', true)
    $('.batch_actions').removeClass('hidden')
    setBatchActionParams()
  } else {
    $('[data-behaviour="bulk-checbox"]').prop('checked', false)
    $('.batch_actions').addClass('hidden')
  }
});

function setBatchActionParams() {
  var selected_ids = []
    $('[data-behaviour="bulk-checbox"]:checked').each(function(){ selected_ids.push($(this).data('object-id')) })
    var url_param = { selected_ids: selected_ids }
    $('.batch_actions .button_to').each(function( i ) {
      var url = this.action
      if (url.indexOf("?") > 0) {
        var a = url.indexOf("?");
        var b =  url.substring(a);
        var url = url.replace(b,"");
      } else {
        url = url
      }
      this.action = url + '?' + $.param(url_param)
      
    })
}