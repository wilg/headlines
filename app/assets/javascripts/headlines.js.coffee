$ ->

  $(".upvote-new").on "ajax:before", ->
    $(@).hide()
    $(@).parent().append("<em> - upvoted!</em>")

  $(".upvote-existing").on "ajax:before", ->
    $(@).hide()
    $(@).parent().append("<em> - upvoted!</em>")