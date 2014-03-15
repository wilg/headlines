window.headlineDetailLoadIds = []

$ ->

  hoverIn = ->
    element = $(@)
    id = element.closest('tr').data('headline-id')
    if window.headlineDetailLoadIds.indexOf(id) is -1
      window.headlineDetailLoadIds.push(id)
      $.getScript element.closest('tr').data('details-url'), ->
        $('.headline-fragment').tooltip()

  hoverOut = ->
    # Nothing

  $('.headlines-table tr .headline-link').hoverIntent
    over: hoverIn
    out: hoverOut
    timeout: 3000
