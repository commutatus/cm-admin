$(document).on('click', '.export-to-file-btn', function(e) {
  e.preventDefault();
  query_param = window.location.href.split("?")[1]
  $('#export-to-file-form').get(0).setAttribute('action', '/cm_admin/export_to_file.js?' + query_param);
  $("#export-to-file-form").submit();
});