$ ->

  username = $('body').data('username')
  if username?

    if $('body').data('newly-registered')?
      mixpanel.alias(username)
      mixpanel.track("Sign Up")
    else
      mixpanel.identify(username)

    mixpanel.people.set
      "$username": username
      "$name": username
      "$created": $('body').data('created')
      "$last_login": $('body').data('signed_in')
      "karma": parseInt($('body').data('karma'), 10)
      "comments": parseInt($('body').data('comments'), 10)
      "saved": parseInt($('body').data('saved'), 10)
      "votes": parseInt($('body').data('votes'), 10)

  mixpanel.track_links '.twitter-share-link', 'Twitter Share', (link) ->
    'Headline ID': $(link).data('headline-id')

  mixpanel.track_links '.facebook-share-link', 'Facebook Share', (link) ->
    'Headline ID': $(link).data('headline-id')

  $(document).on 'show.bs.modal', '#modal-login-form', ->
    mixpanel.track("Signup Form Presented")

  mixpanel.track_links '.read-article-link', 'Read Original Article', (link) ->
    'Headline ID': $(link).data('headline-id')
    'Source Headline ID': $(link).data('id')
    'Source Name': $(link).data('source')

  mixpanel.track_links '.random-headline-link', 'View Random'