$ ->

  window.userSignedIn = -> $("body").hasClass('logged-in')

  generate_new = ->

    $("#invent-button").addClass 'disabled'
    $("#invent-button i").addClass 'fa-spin'
    normal_title = $("#invent-button span").html()
    $("#invent-button span").html($("#invent-button").data('disable-with'))

    $("#generate-form .alert").addClass('hidden')

    # Get checked sources
    source_names = $("#generate-form input:checkbox:checked").map(->
      $(this).attr('name')
    ).get()
    window.generator_last_source_names = source_names
    window.generator_last_depth = 2

    # Build query string
    query = $.param({depth:window.generator_last_depth, sources:source_names.join(",")})

    # Build URL
    url = $("#generate-form").data('generator-url') + "?" + query

    $.getJSON url, (data) ->
      $("#generated-headlines").html HandlebarsTemplates[if window.userSignedIn() then 'generator/results' else 'generator/results_signed_out'](data)
    .fail ->
      $("#generate-form .alert").removeClass('hidden')
    .always ->
      $('.headline-fragment').tooltip()
      $("#invent-button").removeClass 'disabled'
      $("#invent-button i").removeClass 'fa-spin'
      $("#invent-button span").html(normal_title)

  # Auto-generate when opening generator page
  if $("#invent-button").length > 0
    generate_new()

  $("#invent-button").on 'click', ->
    generate_new()

Handlebars.registerHelper 'save_url', (person) ->

  query = $.param
    depth: window.generator_last_depth
    headline: @headline
    hash: @hash
    sources: window.generator_last_source_names.join(",")

  $("#generate-form").data('save-url') + "?" + query