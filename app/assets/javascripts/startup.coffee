jQuery ->
  $(document).ready ->
    setFocusToFirstInputField()

  setFocusToFirstInputField = ->
    firstInput = $('form').find('input,textarea,select').not($("#search_search_text")).not($("#token-input-search_search_text")).not($(".disabled")).filter(':visible:first')
    if (firstInput != null)
        firstInput.focus()
