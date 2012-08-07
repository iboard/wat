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
    $('#toggle-section-banner').click ->
      event.preventDefault()
      $("#section-and-banner").toggle()

  if $('#toggle-page-options').length > 0
    $('#toggle-page-options').click ->
      event.preventDefault()
      $("#page-options").toggle()
