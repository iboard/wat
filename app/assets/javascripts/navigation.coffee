jQuery ->

  if $('.subnav').length > 0
    $(document).scroll ->
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

