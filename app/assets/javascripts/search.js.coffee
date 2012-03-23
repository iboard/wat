jQuery ->
  $("#search-button").remove()
  $("#search_search_text").keyup ->
    controller = $('#search_search_controller').val()
    $.ajax("/"+controller, {
      type: 'GET',
      data: { search: { search_text: $('#search_search_text').val(), search_controller: controller} }
    })
