# Attachment Uploader Scripts
#
jQuery ->
  $(document).ready ->
    $('.attachment-upload-form').ready ->
      $(this).fileupload
        dataType: "script"
        add: (e, data) ->
          file = data.files[0]
          data.context = $(tmpl("template-upload", data.files[0]))
          $('#upload-progress-bar').append(data.context)
          data.submit()
        progress: (e, data) ->
          if data.context
            progress = parseInt(data.loaded / data.total * 100, 10)
            data.context.find('.bar').css('width', progress + '%')
            if progress == 100
              data.context.remove()
