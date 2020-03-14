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

  randomRange = (min, max) ->
    Math.random() * (max - min) + min

  randomItem = (items) ->
    items[Math.floor(Math.random() * items.length)]

  shuffle = (a) ->
    j = undefined
    x = undefined
    i = undefined
    i = a.length - 1
    while i > 0
      j = Math.floor(Math.random() * (i + 1))
      x = a[i]
      a[i] = a[j]
      a[j] = x
      i--
    a

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
    sources = $("#generate-form").data('sources')
    sourcesForGenerate = Object.values(sources).filter((source) -> !source.dead)

    ageRanges = [[20, 365], [20, 45], [15, 60], [365, 3650], [20, 365 * 2]]
    sourceRanges = [[5, sourcesForGenerate.length], [5, 10], [5, 15], [5, 50], [5, sourcesForGenerate.length / 2]]
    lengthRanges = [[max_length / 2, max_length], [max_length / 3, max_length], [max_length / 2, max_length * 1.5], [max_length - 10, max_length + 10]]
    randomizeQuery = ->
      [sourceMin, sourceMax] = randomItem(sourceRanges)
      [ageMin, ageMax] = randomItem(ageRanges)
      [lengthMin, lengthMax] = randomItem(lengthRanges)

      sourceCount = Math.round(randomRange(sourceMin, sourceMax))

      age: Math.round(randomRange(ageMin, ageMax))
      length_max: Math.round(randomRange(lengthMin, lengthMax))
      sourceCount: sourceCount
      sources: shuffle(sourcesForGenerate)[...sourceCount].map((source) -> source.id).join(",")
      count: count

    query = randomizeQuery()
    console.log("Generating with settings:", query)

    # Build URL
    url = $("#generate-form").data('generator-url')

    mixpanel.track("Generate", {
      Age: age
      # "Sources": source_names
      # "Depth": window.generator_last_depth
      # "Seed Word" : seed_word
    })

    $.post url, query, (data) ->
      data.headlines = data.headlines.filter((h) ->
        if h.sources
          for source in h.sources
            metadata = sources[source.source_id]
            icon = if metadata
              "<img class='source-icon' alt='#{metadata.name}' src='#{metadata.image_url}' /> "
            else
              ""
            source.tooltip = "<span class='sourcename'>#{icon}#{metadata?.name || source.source_id}:</span> #{source.source_phrase}"
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
