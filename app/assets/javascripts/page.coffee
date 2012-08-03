jQuery ->

  if $('#scroll-to').length > 0
    $('#scroll-to').ready ->
      $('#banner').ready ->
        offset = $('#scroll-to').data('offset')
        y = $('.carousel-caption').position().top + offset
        setTimeout("skipBanner(#{y})",500)

  self.skipBanner = (y) ->
    $('body').animate( {scrollTop : y  },'slow')
