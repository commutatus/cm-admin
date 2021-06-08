$(document).on('click', '.row-action-tool', function(e) {
  e.stopPropagation();
  if ($('.export-popup').hasClass('hidden')) {
    return $('.export-popup').removeClass('hidden');
  } else {
    return $('.export-popup').addClass('hidden');
  }
});
