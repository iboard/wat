$(window).load ->
  setFocusToFirstInputField()

this.setFocusToFirstInputField = ->
  $("input").not($("#search_search_text")).not($("#token-input-search_search_text")).not($(".disabled")).not($("input[type=hidden]")).first().focus()
