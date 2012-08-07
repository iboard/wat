jQuery ->

  if $('#comment_comment_comment').length > 0
    $('#comment_comment_comment').ready ->
      y = $('#comment_comment_comment').position().top
      $('body').animate( {scrollTop : y  },'fast')

  if $('.close-comments-button').length > 0
    $('.close-comments-button').click ->
      event.preventDefault()
      $(this).prev().html('')
      $(this).hide()