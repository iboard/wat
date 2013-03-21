jQuery ->

  if $('#toggle-section-banner').length > 0
    $('#toggle-section-banner').click (event) ->
      event.preventDefault()
      $("#section-and-banner").toggle()

  if $('#toggle-page-options').length > 0
    $('#toggle-page-options').click (event) ->
      event.preventDefault()
      $("#page-options").toggle()

  if $('#toggle-versions-list').length > 0
    $('#toggle-versions-list').click (event) ->
      event.preventDefault()
      $('#version-list').toggle(250)
