jQuery ->

  if $('#comment_comment_comment').length > 0
    $('#comment_comment_comment').ready ->
      y = $('#comment_comment_comment').position().top
      $('body').animate( {scrollTop : y  },'fast')
