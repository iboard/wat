jQuery ->

  $(document).ready ->

    # Show the Timeline-View if chevron points down (view is opened)
    # Events are rendered already, so just show not restart
    if $('#timeline-display').length > 0
      _state = $('#timeline-display').attr('class')
      if _state == "icon-chevron-down icon-white timeline-toggle"
        showTimelineEvents()
    else if $('#events').length > 0
      # Restart the timer (the first time)
      restartTimelineUpdater()

    # Put a div with id open-timeline into your view to trigger this function
    # If the timeline-view is open (chevron points down) show the events
    # Restart the timer
    if $('#open-timeline').length > 0
      if _state == "icon-chevron-down icon-white timeline-toggle"
        showTimelineEvents()
      latest_events = ""
      setTimeout( "restartTimelineUpdater()", 2000 )

  # Called from views/timelines/toggle.js.erb
  self.toggleTimeline = (state) ->
    if state == 'hidden'
      hideTimeline()
    else
      showTimeline()

  # Animate TimelineView to close
  self.hideTimeline = ->
    $('#input-text').hide(150)
    $('#timeline').animate( height: '25px', 500)
    $('#timeline #events').hide()
    $('#timeline-display').attr('class','icon-chevron-up icon-white timeline-toggle')

  # Animate TimelineView to open
  self.showTimeline = (_time = 500) ->
    $('#timeline #events').show()
    $('#timeline').animate( height: '300px', _time)
    $('#timeline-display').attr('class','icon-chevron-down icon-white timeline-toggle')
    $('#input-text').show(_time)

  # Request new events since last_update (Hidden field with Time as string)
  # latest_events and interval_in_seconds is set by views/timelines/update_timeline.js.erb
  self.restartTimelineUpdater = () ->
    $.ajax "/timelines/update_timeline?since=" + $('#last_update').val(),
      success  : (res, status, xhr) ->
        $('#last_update').val( last_update )
        if latest_events.length > 0
          dropInEvent(latest_events)
        setTimeout( "restartTimelineUpdater()", interval_in_seconds )
      error    : (xhr, status, err) ->
        $('#timeline #entries').html( "<div class='alert alert-info'>
                                       No Timeline available at the moment.<hr/>
                                      Im Augenblick ist keine Timeline verfügbar.")
        setTimeout( "restartTimelineUpdater()", 60000 )

  self.dropInEvent = (latest_events) ->
    if ('#events').length > 0
      $('ul#events li:first').prepend( latest_events )
      $('.new-entry').show('blind', direction: 'vertical', 2000).removeClass('new-entry')

  self.showTimelineEvents = ->
    $('.new-entry').show()
    $('#timeline').height(300)
    $('#new-entry').show()
    $('#input-text').show(-10)

  # Triggers for Subscription-check-boxes

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
        dropInEvent(latest_events)
        $('#response').html( "<div class='alert alert-info'>" + message + "</div>")
      error    : (xhr, status, err) ->
        alert "Can't change subscription for this timeline / Abo kann nicht geändert werden\n\nError: " + err + "\n" + _path

  # @deprecated, just left it for one commit because it was so much pain to do
  self.currentDate = ->
    # Because JavaScript doesn't have a Time.now.to_s ...
    _date = new Date()
    _y = _date.getFullYear()
    _m = _date.getMonth()
    _d = _date.getDay()
    _h = _date.getHours()
    _n = _date.getMinutes()
    _s = _date.getSeconds()
    _z = _date.getTimezoneOffset()
    _Y = _y.toString()
    _M = if (_m < 10) then ("0"+_m.toString()) else _m.toString()
    _D = if (_d < 10) then ("0"+_d.toString()) else _d.toString()
    _H = if (_h < 10) then ("0"+_h.toString()) else _h.toString()
    _N = if (_n < 10) then ("0"+_n.toString()) else _n.toString()
    _S = if (_s < 10) then ("0"+_s.toString()) else _s.toString()
    _zone_time = _z/60*100
    _dir = if _zone_time > 0 then "-" else "+"
    _zone_time *= -1 if _zone_time < 0
    _Z = if _zone_time < 1000 then "0"+_zone_time.toString() else _zone_time.toString()
    _x = _Y+"-"+_M+"-"+_D+" "+_H+":"+_N+":"+_S+ " " + _dir + _Z
