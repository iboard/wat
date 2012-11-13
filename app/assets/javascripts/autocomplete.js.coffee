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
    propertyToSearch: "search_name",
    tokenValue: 'name',
    tokenFormatter: (item) -> "<li><p>" + item[this.tokenValue] + "</p></li>"
  })
