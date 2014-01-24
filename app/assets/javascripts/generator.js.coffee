$ ->

  # Group Selection Checkboxes
  update_checkbox_statuses = ->
    $('.source-category').each (index, category) ->
      category = $(category)
      if category.find(".source-check-box:checked").length is 0
        category.find(".group-check-box").prop("indeterminate", false).prop("checked", false)
      else if category.find(".source-check-box:not(:checked)").length is 0
        category.find(".group-check-box").prop("indeterminate", false).prop("checked", true)
      else
        category.find(".group-check-box").prop("indeterminate", true)

  update_checkbox_statuses()
  $(".source-check-box").change -> update_checkbox_statuses()

  $(".group-check-box").change ->
    $(this).closest('.source-category').find(".source-check-box").prop("checked", $(this).is(":checked"))

  $(document).on "click", "#select-all", ->
    $('.group-check-box').prop("checked", true).prop("indeterminate", false)
    $('.source-check-box').prop("checked", true)

  $(document).on "click", "#select-none", ->
    $('.group-check-box').prop("checked", false).prop("indeterminate", false)
    $('.source-check-box').prop("checked", false)

  $('.headline-fragment').tooltip()

  $(document).on "click", ".save-headline-button", ->
    $(@).closest('form').submit()

  $('.source-category .toggler').click (event) ->
    $(@).find('i').toggleClass('fa-caret-down')
    $(@).find('i').toggleClass('fa-caret-right')
    event.preventDefault()

  mobile_generator_layout = ->
    if $(window).width() > 992
      $("#collapse-generate-options").hide()
      $("#generate-form .source-box").removeClass("collapse")
    else
      $("#collapse-generate-options").show()

  if $("#collapse-generate-options").length > 0
    mobile_generator_layout()
    $(window).resize -> mobile_generator_layout()

  window.userSignedIn = -> $("body").hasClass('logged-in')

  generate_new = ->

    $("#invent-button").addClass 'disabled'
    $("#invent-button").removeClass 'enabled'

    $("#generate-form .alert").addClass('hidden')

    # Get checked sources
    source_names = $("#generate-form input:checkbox:checked").map(->
      $(this).attr('name')
    ).get()
    window.generator_last_source_names = source_names
    window.generator_last_depth = 2 #$("#generate-form input:radio[name=depth]:checked").val();
    seed_word = $("#generate-form input[name=seed_word]").val().split(' ')[0]

    if $("#generate-form").data('reconstruct-phrase')
      # Try reconstructing, ignore form
      query = $.param
        reconstruct: $("#generate-form").data('reconstruct-phrase')
        sources: $("#generate-form").data('reconstruct-sources')
    else
      # Use the form params
      query = $.param({depth:window.generator_last_depth, seed_word:seed_word, sources:source_names.join(",")})

    # Build URL
    url = $("#generate-form").data('generator-url') + "?" + query

    $.getJSON url, (data) ->
      $("#generated-headlines").html HandlebarsTemplates[if window.userSignedIn() then 'generator/results' else 'generator/results_signed_out'](data)
    .fail ->
      $("#generate-form .alert").removeClass('hidden')
    .always ->
      $('.headline-fragment').tooltip()
      $("#invent-button").removeClass 'disabled'
      $("#invent-button").addClass 'enabled'

  $("#generate-form").submit (event) ->
    generate_new();
    event.preventDefault()

  # Auto-generate when opening generator page
  if $("#invent-button").length > 0
    generate_new();

  $("#invent-button").on 'click', ->
    $("#generate-form").submit()


Handlebars.registerHelper 'authenticity_token', ->
  $('meta[name="csrf-token"]').attr('content')

Handlebars.registerHelper 'sources_json', ->
  JSON.stringify @sources

Handlebars.registerHelper 'save_url', ->
  $("#generate-form").data('save-url')
