jQuery ->

  if $('#scroll-to').length > 0
    $('#scroll-to').ready ->
      $('#banner').ready ->
        offset = $('#scroll-to').data('offset')
        y = $('#scroll-to').position().top + offset
        setTimeout("skipBanner(#{y})",500)

  self.skipBanner = (y) ->
    $('body').animate( {scrollTop : y  },'slow')


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
