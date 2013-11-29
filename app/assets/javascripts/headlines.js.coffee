$ ->

  $(".upvote-new").on "ajax:before", ->
    $(@).hide()
    $(@).parent().append("<span class='text-success'>upvoted!</span>")

  $(".upvote-existing").on "ajax:before", ->
    $(@).hide()
    $(@).parent().append("<span class='text-success'>upvoted!</span>")