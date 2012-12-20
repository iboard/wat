jQuery ->

  if $('.search-query').length > 0
    _controller = $('.search-query').data('controller')
    _hintText = $('.search-query').data('hint-text')
    _noResultsText = $('.search-query').data('no-results-text')
    _searchingText = $('.search-query').data('searching-text')

  $(".search-query").tokenInput("/#{_controller}/autocomplete_search.json", {
    crossDomain: false,
    theme: "wat",
    hintText: _hintText,
    noResultsText: _noResultsText,
    searchingText: _searchingText,
    preventDuplicates: true,
    propertyToSearch: "list_name",
    tokenValue: 'search_name',
    tokenFormatter: (item) -> "<li><p>" + item[this.tokenValue] + "</p></li>",
    onAdd: (item) -> tokenInputSearch()
    onDelete: (item) -> window.location.reload()
  })

  if $('#token-input-search_search_text').length > 0
    _placeholderText = $('.search-query').data('placeholder')
    $('#token-input-search_search_text').attr("placeholder", _placeholderText )
    $("#search-button").remove()
    $("#token-input-search_search_text").live('keyup', (event) -> 
      if event.keyCode == 13
        tokenInputSearch()
      )

  self.tokenInputSearch = () ->
    _value = $('.token-input-token-wat p').html() || $('tester').html() || $('tester').val()
    controller = $('#search_search_controller').val() || 'pages'
    $.ajax("/"+controller, {
      type: 'GET',
      data: { search: { search_text: _value, search_controller: controller} }
    })
