$(document).on('click', '.export-to-file-btn', function(e) {
  e.preventDefault();
  var query_param = window.location.href.split("?")[1]
  $("#export-to-file-form").submit();
});