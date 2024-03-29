$(document).on('click', '.kanban-show-more', function(e) {
  e.preventDefault();
  var page = $(this).data('page') + 1
  var query_string = window.location.search
  $.ajax('/admin/batch_order_items' + query_string, {
    type: "GET",
    data: {
      page: page,
      per_page: $(this).data('per-page'),
      view_type: 'kanban'
    },
    success: function (data) {
      apply_response_to_board(data.table.data);
      $('.kanban-show-more').data('page', page)
      if (data.table.paging.next_page == false) {
        $('.kanban-show-more').addClass('disabled')
      }
      $('.kanban-show-more').data('page', page)
    },
    error: function (jqxhr, textStatus, errorThrown) {
      alert("Something went wrong. Please try again later.\n" + errorThrown);
    },
  });
})

function apply_response_to_board(json_data) {
  $.each(json_data, function(key, value) {
    $('.' + key + ' .cards').append(value)
  });
}