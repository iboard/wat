jQuery ->

  if $('.subnav').length > 0

    $(window).resize ->
      adjustFirstPillLeft()

    $(document).scroll ->
      adjustFirstPillLeft()

      if !$('.subnav').attr('data-top')
        unless $('.subnav').hasClass('subnav-fixed')
          offset = $('.subnav').offset()
          if offset && offset.top
            $('.subnav').attr('data-top', offset.top )
    
      if $('.subnav').attr('data-top')
        if( $('.subnav').attr('data-top') - $('.subnav').outerHeight() <= $(this).scrollTop())
          $('.subnav').addClass('subnav-fixed')
        else
          $('.subnav').removeClass('subnav-fixed')

  adjustFirstPillLeft= ->
    if $('.subnav-fixed').length > 0
      brand_offset = $('a.brand').offset()
      left_offset = brand_offset.left
      if left_offset > 0
        subnav_left = left_offset+20
      else
        subnav_left = 0
      $('.subnav.subnav-fixed .span8 .nav.nav-pills > li:first-child > a').attr('style', 'margin-left: ' + subnav_left + "px;" )
    unless $('.subnav.subnav-fixed .span8 .nav.nav-pills > li:first-child > a').length
      $('.subnav .span8 .nav.nav-pills > li:first-child > a').attr('style', '' )
  