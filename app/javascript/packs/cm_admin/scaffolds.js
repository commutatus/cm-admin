$(document).on('turbolinks:load', function () {
  $('.select-2').select2({
    theme: "bootstrap-5",
  });
  flatpickr("[data-behaviour='date-only']", {
    dateFormat: "d-m-Y"
  })
  flatpickr("[data-behaviour='date-time']", {
    enableTime: true
  })
  flatpickr("[data-behaviour='filter'][data-filter-type='date']", {
    mode: 'range'
  })
  var el = document.getElementsByClassName('columns-list')
  if(el[0]) {
    Sortable.create(el[0],{
      handle: '.dragger',
      animation: 150
    });
  }

  // var array = $('#searchKeywords').val().split(",");
  // $.each(array,function(i){
  //   alert(array[i]);
  // });
 
  // var el = document.getElementsByClassName('kanban-list')
  // if(el[0]) {
  //   Sortable.create(el,{
  //     handle: '.kanban-item',
  //     animation: 150
  //   });
  // }

  var headerElemHeight = $('.page-top-bar').height() + 64
  var calculatedHeight = "calc(100vh - " + headerElemHeight+"px"+")"
  $('.table-wrapper').css("maxHeight", calculatedHeight);
});