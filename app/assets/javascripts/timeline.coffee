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


  if $('#hide-timeline').length > 0
    $('#hide-timeline').ready ->
      hideTimeline()

  if $('.subsribe-timeline-by-email-checkbox').length > 0
    $('.subsribe-timeline-by-email-checkbox').change ->
      event.preventDefault()
      alert "This function is not implemented yet<br/>Die Funktion ist noch nicht implementiert."

  if $('.subsribe-timeline-on-screen-checkbox').length > 0
    $('.subsribe-timeline-on-screen-checkbox').change ->
      event.preventDefault()
      subscribeUserTimeline($(this))

  self.subscribeUserTimeline = (checkbox) ->
    timelineId = $(checkbox).data('id')
    userId = $(checkbox).data('user')
    newState = $(checkbox).attr('checked')
    _path =  "/users/" + userId + "/timeline_subscription/" + timelineId + "/"
    if newState == 'checked'
      _path += 'subscribe.js'
    else
      _path += 'unsubscribe.js'
    $.ajax _path,
      success  : (res, status, xhr) ->
        $('#timeline #entries').html(latest_events)
        $('#timeline #entries .latest-timeline-event').effect('highlight', {}, 4000)
        $('#events').html(latest_events)
        $('#response').html( "<div class='alert alert-info'>" + message + "</div>")
      error    : (xhr, status, err) ->
        alert "Can't change subscription for this timeline / Abo kann nicht geändert werden\n\nError: " + err + "\n" + _path


