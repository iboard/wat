jQuery ->

  _controller = $('.search-query').data('controller')

  $(".search-query").tokenInput("/#{_controller}/autocomplete_search.json", {
    crossDomain: false,
    theme: "mac",
    hintText: "Search #{_controller}...",
    preventDuplicates: true,
    tokenValue: 'name'
  })
