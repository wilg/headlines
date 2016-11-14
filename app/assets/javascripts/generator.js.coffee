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
  $('.source-icon-link').tooltip()

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

  runGenerate = ->

    $('html, body').animate({
      scrollTop: $(".generate-button").first().offset().top - 15
    }, 1000)

    $(".generate-button").addClass 'disabled'
    $(".generate-button").removeClass 'enabled'

    $("#generate-form .alert").addClass('hidden')

    # Get checked sources
    # source_names = $("#generate-form input:checkbox:checked").map(->
    #   $(this).attr('name')
    # ).get()
    # window.generator_last_source_names = source_names
    # window.generator_last_depth = 2 #$("#generate-form input:radio[name=depth]:checked").val();
    # seed_word = $("#generate-form input[name=seed_word]").val().split(' ')[0]

    # if $("#generate-form").data('reconstruct-phrase')
    #   # Try reconstructing, ignore form
    #   query = $.param
    #     reconstruct: $("#generate-form").data('reconstruct-phrase')
    #     sources: $("#generate-form").data('reconstruct-sources')
    # else
    #   # Use the form params
    #   query = $.param
    #     depth: window.generator_last_depth
    #     seed_word: seed_word
    #     sources: source_names.join(",")

    age = window.generator_age || $("#generate-form").data('age')
    count = window.generator_count || $("#generate-form").data('count')
    max_length = window.generator_max_length || $("#generate-form").data('max-length')
    disallowed_words = $("#generate-form").data('disallowed-words')

    query = $.param
      age: age
      count: count
      length_max: max_length

    # Build URL
    url = $("#generate-form").data('generator-url') + "?" + query

    mixpanel.track("Generate", {
      Age: age
      # "Sources": source_names
      # "Depth": window.generator_last_depth
      # "Seed Word" : seed_word
    })

    $.getJSON url, (data) ->
      data.headlines = data.headlines.filter((h) ->
        for word in disallowed_words
          if h.headline.toLowerCase().indexOf(word) != -1
            return false
        return true
      )
      $("#generated-headlines").html HandlebarsTemplates[if window.userSignedIn() then 'generator/results' else 'generator/results_signed_out'](data)
    .fail ->
      $("#generate-form .alert").removeClass('hidden')
    .always ->
      $('.headline-fragment').tooltip()
      $(".generate-button").removeClass 'disabled'
      $(".generate-button").addClass 'enabled'
      $(".generate-button-wrapper").show()

  $("#generate-form").submit (event) ->
    runGenerate();
    event.preventDefault()

  # Auto-generate when opening generator page
  if $(".generate-button").length > 0
    runGenerate()

  $(".generate-button").on 'click', ->
    $("#generate-form").submit()


Handlebars.registerHelper 'authenticity_token', ->
  $('meta[name="csrf-token"]').attr('content')

Handlebars.registerHelper 'sources_json', ->
  JSON.stringify @sources

Handlebars.registerHelper 'save_url', ->
  $("#generate-form").data('save-url')
