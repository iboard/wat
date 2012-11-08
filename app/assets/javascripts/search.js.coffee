jQuery ->
  if $('#token-input-search_search_text').length > 0
    _placeholderText = $('.search-query').data('placeholder')
    $('#token-input-search_search_text').attr("placeholder", _placeholderText )

  $("#search-button").remove()
  $("#token-input-search_search_text").keyup (event) ->
    if event.keyCode == 13
      _value = $('.token-input-token-wwedu p').html() || $('tester').html() || $('tester').val()
      controller = $('#search_search_controller').val()
      $.ajax("/"+controller, {
        type: 'GET',
        data: { search: { search_text: _value, search_controller: controller} }
      })
      $(".token-input-list").remove()
