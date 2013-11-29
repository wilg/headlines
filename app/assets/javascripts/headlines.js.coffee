$ ->
  vote_button_action()
  $(document).ajaxStop ->
    vote_button_action()


vote_button_action = ->
  $(".upvote-button").off "ajax:complete"
  $(".upvote-button").on "ajax:complete", ->
    votecount = $(@).closest("tr").find(".vote-count")
    if votecount?
      votes = parseInt votecount.text()
      votecount.text(votes + 1)
    $(@).hide()
    $(@).parent().append $("#upvoted-button").html()
