# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  if $('#slides.carousel').length > 0
    $('#slides.carousel').ready ->
      $('#slides.carousel').carousel('cycle',{interval:2500, pause: 'hover'})

  if $('.navbar').length > 0
    $('.navbar').click ->
      $('body').animate({scrollTop : 0},'slow')