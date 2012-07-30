$('#cropbox').ready ->
  new AvatarCropper()

class AvatarCropper
  constructor: ->
    $('#cropbox').Jcrop
      aspectRatio: 1.0
      setSelect: [0, 0, 100, 100]
      minSize: [100,100]
      onSelect: @update
      onChange: @update
    
  update: (coords) =>
    if $('#avatar_original').val() <= 100
      alert "WARNING: Image is to small min 100px!"
    scale = parseInt($('#avatar_original').val()) / parseInt($('#avatar_large').val())
    $('#crop_x').val(coords.x*scale)
    $('#crop_y').val(coords.y*scale)
    $('#crop_w').val(coords.w*scale)
    $('#crop_h').val(coords.h*scale)
    @updatePreview(coords)
  
  updatePreview: (coords) =>
    $('#preview').css
      width: Math.round(100/coords.w * $('#cropbox').width()) + 'px'
      height: Math.round(100/coords.h * $('#cropbox').height()) + 'px'
      marginLeft: '-' + Math.round(100/coords.w * coords.x) + 'px'
      marginTop: '-' + Math.round(100/coords.h * coords.y ) + 'px'
      overflow: 'hidden'
  