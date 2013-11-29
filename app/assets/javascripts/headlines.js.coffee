$ ->

  $(".upvote-button").on "ajax:before", ->
    votecount = $(@).closest("tr").find(".vote-count")
    if votecount?
      votes = parseInt votecount.text()
      votecount.text(votes + 1)
    $(@).hide()
    $(@).parent().append $("#upvoted-button").html()