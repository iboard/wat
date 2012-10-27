jQuery ->

  $('.locale-line').live 'click', (event) ->
    event.preventDefault()
    translator = new Translator($(this).data('key'),$(this).data('locale'),$(this).data('value'))

class Translator
  constructor: (_key,_locale,_default) ->
    @locale = _locale
    @default = _default
    @key = _key
    @is_counter = @default instanceof Object

    bootbox.dialog( @dialog, [
      {"label": "OK", "class":"btn-primary", "callback": @update},
      {"label": "Cancel", "class":"btn-default", "callback": @cancel},
    ])

  dialog: =>
    html_form = "<h1>Translate</h1>" +
    "<p>Locale: #{@locale}<br/>Key: #{@key}</p><form>"
    if !@is_counter
      html_form += "<textarea id='new-translation' style='width: 90%'>#{@default}</textarea>"
    else
      html_form += "Zero:<br/><input type='text' name='zero' style='width: 90%' id='new-translation-zero' value='"
      html_form += @remove_extra_chars(@default['zero']) + "'>"
      html_form += "<br/><br/>One:<br/><input name='one' type='text' style='width: 90%' id='new-translation-one' value='"
      html_form += @remove_extra_chars(@default['one']) + "'>"
      html_form += "<br/></br>Other:<br/><input name='other' type='text' style='width: 90%' id='new-translation-other' value='"
      html_form += @remove_extra_chars(@default['other']) + "'>"
    html_form += "</form>"
    return html_form

  update: =>
    if @is_counter
      result = {
       'zero': $('#new-translation-zero').val(),
       'one':  $('#new-translation-one').val(),
       'other':$('#new-translation-other').val()
      }
    else
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

  remove_extra_chars: (_str) =>
    _str.replace(/^\[\"/, '').replace(/\"\]$/,'').replace(/'/g, '&#39;')


