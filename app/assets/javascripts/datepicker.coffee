jQuery ->


  if $('.add-on.datepicker').length > 0
    $('.add-on.datepicker').click ->
      $(this).parent().datepicker()