jQuery ->

  $('.locale-line').click (event) ->
    event.preventDefault()
    translator = new Translator($(this).data('key'),$(this).data('locale'),$(this).data('value'))

class Translator
  constructor: (_key,_locale,_default) ->
    @locale = _locale
    @default = _default
    @key = _key
    bootbox.dialog( @dialog, [
      {"label": "OK", "class":"btn-primary", "callback": @update},
      {"label": "Cancel", "class":"btn-default", "callback": @cancel},
    ])

  dialog: =>
    "<h1>Translate</h1>" +
    "<p>Locale: #{@locale}<br/>Key: #{@key}</p>" +
    "<form><textarea id='new-translation' style='width: 90%'>#{@default}</textarea></form>"

  update: =>
    result = $('#new-translation').val()
    $.ajax("/translations", {
      type: 'POST',
      data: {
        translation: {
          locale: @locale,
          key: @key,
          value: result
        }
      }
    })

  cancel: =>
    # NOOP


