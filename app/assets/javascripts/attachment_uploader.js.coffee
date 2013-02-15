# Attachment Uploader Scripts
#
jQuery ->
  $(document).ready ->
    if $('.attachment-upload').length > 0
      registerFilesUpload()
    if $(".attachment-single-upload").length > 0
      registerUploadField()

  self.registerFilesUpload = () ->
    $(".attachment-upload").ready ->
      $(this).fileupload
        limitConcurrentUploads: 1
        dropZone: $('.upload-area')
        preview = $(this).find('.fileupload-preview')
        _controller_function = $('.attachment_file_add').data('controller-function')
        file_names = ""
        preview.text( file_names )
        dataType: "script"
        add: (e, data) ->
          file = data.files[0]
          data.context = $(tmpl("template-upload", file))
          $(".upload-progress-bar").append(data.context)
          file_names += "[" + file.name + "]"
          preview.text( file_names )
          data.submit()
        done: (e, data) ->
          data.context.remove()
        progress: (e, data) ->
          if data.context
            progress = parseInt(data.loaded / data.total * 100, 10)
            data.context.find('.bar').css('width', progress + '%')
        progressall: (e, data) ->
          if $('#template-upload-all').length > 0
            if !data.context_all
              data.context_all = $(tmpl("template-upload-all", data))
              $(".upload-all-progress-bar").html(data.context_all)
            if data.context_all
              progress = parseInt(data.loaded / data.total * 100, 10)
              data.context_all.find('.bar').css('width', progress + '%')
        stop: (e) ->
          preview.text( "" )
          if _controller_function && _controller_function != ""
            $.ajax("/" + _controller_function, {
              type: 'GET'
            })

  self.registerUploadField = () ->
    $(".attachment-single-upload").ready ->
      $('.fileupload-files').live('change', (e) -> ( fileFieldChanged(e);) )

  self.fileFieldChanged = (e) ->
    file = e.target.files[0]
    preview = $('.fileupload-preview')
    preview.text( file.name )
