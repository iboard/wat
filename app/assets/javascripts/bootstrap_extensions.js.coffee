jQuery ->
  if $("a[rel=popover]").count > 0
    $("a[rel=popover]").popover()
  if $(".tooltip").count > 0
    $(".tooltip").tooltip()
  if $("a[rel=tooltip]").count > 0
    $("a[rel=tooltip]").tooltip()