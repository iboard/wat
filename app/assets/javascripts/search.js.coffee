jQuery ->
  $("#search-button").remove()
  $("#token-input-search_search_text").keyup (event) ->
    # event.keyCode == 13 is equivalent to 'enter'
    if event.keyCode == 13
      controller = $('#search_search_controller').val()
      $.ajax("/"+controller, {
        type: 'GET',
        data: { search: { search_text: $('#search_search_text').val(), search_controller: controller} }
      })
