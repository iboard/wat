jQuery ->

  currentPage = 1
  state_scroll_to_top_link = 0
  bottom_announced = 0

  self.insert_load_button = (where,txt,path) ->
    target = $("#"+where)
    id = 'load_more_link'
    target.html("<div id='"+id+"'><img src='/images/spinner.gif' title='Loading...' /> "+txt+"</div>")
    $.ajax({ url: path, context: where })

  self.smoothToTop = ->
    $("html body").animate( { scrollTop: 0 }, 750)

  self.checkScroll = ->
    if (nearBottomOfPage())
      currentPage += 1
      $('#load_more_link').click()
    else
      setTimeout("checkScroll()", 500)

  self.controllToTopLink = ->
    if( onTop() )
      if( state_scroll_to_top_link == 1 )
        $('#scroll-to-top').effect('puff',{},500)
        state_scroll_to_top_link = 0
    else
      if( state_scroll_to_top_link == 0 )
        $('#scroll-to-top').fadeTo(250,0.75)
        state_scroll_to_top_link = 1
      if(scrolledPercentage() >= 99)
        if( bottom_announced == 0)
          $('#scroll-to-top').effect('pulsate',{times: 2},250)
          bottom_announced = 1
      else
        bottom_announced = 0
    setTimeout("controllToTopLink()", 500)

  self.nearBottomOfPage = ->
    scrollDistanceFromBottom() < 250

  self.scrollDistanceFromBottom = (argument) ->
    pageHeight() - (window.pageYOffset + self.innerHeight)

  self.pageHeight = ->
    Math.max(document.body.scrollHeight, document.body.offsetHeight)

  self.scrolledPercentage = ->
    ((document.body.scrollHeight)-scrollDistanceFromBottom())/document.body.scrollHeight*100

  self.onTop = ->
    visible=0
    f = scrolledPercentage()-visible
    $("#scroll-position").html(sprintf("%d%",f))
    window.pageYOffset <= 0

  $(document).ready ->
    $(".pagination_box:first").hide()
    $('#scroll-to-top').hide()
    controllToTopLink()
    checkScroll()

