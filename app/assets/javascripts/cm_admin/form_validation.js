$(document).on('click', '.form_submit', function(e) {
  console.log('Came here')
  e.preventDefault();
  var submit = [];
  var form_class = $(this).data('form-class');
  $("." + form_class + " input.required, ." + form_class + " textarea.required").each(function() {
    $(this).removeClass('error');
    if ($(this).val().trim().length === 0) {
      $(this).addClass('error');
      $(this)[0].scrollIntoView(true);
      submit.push(true);
    }
  });
  $("." + form_class + " select.required").each(function() {
    $(this).removeClass('error');
    if ($(this).val().trim().length === 0) {
      $(this).parent().find('.select2').addClass('error');
      $(this)[0].scrollIntoView(true);
      submit.push(true);
    }
  });
  $('.nested_input_validation').each(function() {
    var class_name;
    class_name = $(this).data('class-name');
    $(this).parents(':nth(1)').find('.' + class_name).addClass('hidden');
    if ($(this).val().trim().length === 0) {
      $(this).parents(':nth(1)').find('.' + class_name).removeClass('hidden');
      $(this)[0].scrollIntoView(true);
      submit.push(true);
    }
  });
  if (submit.length === 0) {
    $('.' + form_class).submit();
    return $('.form_submit').button('loading');
  }
});
