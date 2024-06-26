var CmFilter = {
  quick_input_search: function(element) {
    var filter = element.val().toUpperCase();
    var searchElements = element.parents(':nth(3)').find('.list-area').children();
    searchElements.removeClass('visible').addClass('hidden')
    for (var i = 0; i < searchElements.length; i++) {
      var txtValue = $(searchElements[i]).children().text();
      if (txtValue.toUpperCase().indexOf(filter) > -1) {
        $(searchElements[i]).removeClass('hidden').addClass('visible');
      }
    }
  }
}

$(document).on("keydown", function(e) {
  if (e.keyCode == 75 && e.metaKey) {
    $('#quickSearchModal').modal('show')
  }
});

var liSelected;
$(document).on('keydown', function(e){
  var sel_item = $('.search-results-container > a.visible');
  if ($('#quickSearchModal').hasClass('show')) {
    var selected;
    if(e.which === 40){
      if(liSelected){
        liSelected.removeClass('active-item');
        var next = liSelected.next();
        if(next.length > 0){
          liSelected = next.addClass('active-item');
          selected = next.text();

        }else{
          liSelected = sel_item.eq(0).addClass('active-item');
          selected = sel_item.eq(0).text();
        }
      }else{
        liSelected = sel_item.eq(0).addClass('active-item');
        selected = sel_item.eq(0).text();
      }
    }else if(e.which === 38){
      if(liSelected){
        liSelected.removeClass('active-item');
        next = liSelected.prev();
        if(next.length > 0){
          liSelected = next.addClass('active-item');
          selected = next.text();

        }else{

          liSelected = sel_item.last().addClass('active-item');
          selected = sel_item.last().text()
        }
      }else{
        liSelected = sel_item.last().addClass('active-item');
        selected = sel_item.last().text()
      }
    }
    if(liSelected && e.which === 13) {
      var href = liSelected.attr('href')
      window.location = href
    }
  }
});

$(document).on('keyup', '[data-behaviour="quick-input-search"]', function(e) {
  if ($(this).val().length > 0) {
    $('.clear-search').removeClass('hidden')
  } else {
    $('.clear-search').addClass('hidden')
  }
  CmFilter.quick_input_search($(this))
});

$(document).on('click', '.clear-search', function(){
  $('#quick-search-input').val('')
  $('.clear-search').addClass('hidden')
  CmFilter.quick_input_search($('#quick-search-input'))
});