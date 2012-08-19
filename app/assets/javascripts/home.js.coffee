jQuery ->
  if $('#slides.carousel').length > 0
    $('#slides.carousel').ready ->
      $('#slides.carousel').carousel('cycle',{interval:2500, pause: 'hover'})

  if $('.navbar').length > 0
    $('.navbar').click ->
      $('body').animate({scrollTop : 0},'slow')