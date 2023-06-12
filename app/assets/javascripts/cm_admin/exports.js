$(document).on('click', '.export-to-file-btn', function(e) {
  e.preventDefault();
  var query_param = window.location.href.split("?")[1]
  var action = $('#export-to-file-form').get(0).getAttribute('action')
  $('#export-to-file-form').get(0).setAttribute('action', action + '?' + query_param);
  $("#export-to-file-form").submit();
});