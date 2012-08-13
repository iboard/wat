jQuery ->

  self.toggleTimeline = (state) ->
    if state == 'hidden'
      hideTimeline()
    else
      showTimeline()

  self.hideTimeline = ->
    $('#input-text').hide(150)
    $('#timeline').animate( height: '25px', 500)
    $('#timeline #events').hide()
    $('#timeline-display').attr('class','icon-chevron-up icon-white timeline-toggle')

  self.showTimeline = ->
    $('#timeline #events').show()
    $('#timeline').animate( height: '300px', 500)
    $('#timeline-display').attr('class','icon-chevron-down icon-white timeline-toggle')
    $('#input-text').show(500)


  $('#timeline-display').ready ->
    _state = $('#timeline-display').attr('class')
    if _state == "icon-chevron-down icon-white timeline-toggle"
      restartTimelineUpdater()
      $('#timeline').animate( height: '300px', 200)
      $('#input-text').show(250)


  self.restartTimelineUpdater = () ->
    $.ajax "/timelines/update_timeline",
      success  : (res, status, xhr) ->
        $('#timeline #entries').html(latest_events)
        $('#timeline #entries .latest-timeline-event').effect('highlight', {}, 4000)
        setTimeout( "restartTimelineUpdater()", 5000 )
      error    : (xhr, status, err) ->
        $('#timeline #entries').html( "<div class='alert alert-info'>
                                       No Timeline available at the moment.<hr/>
                                      Im Augenblick ist keine Timeline verfügbar.") 
        setTimeout( "restartTimelineUpdater()", 60000 )

      

    

