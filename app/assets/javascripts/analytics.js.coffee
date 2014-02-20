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
      "votes": parseInt($('body').data('votes'), 10)

  $(document).on 'click', '.twitter-share-link', ->
    mixpanel.track("Twitter Share")

  $(document).on 'click', '.facebook-share-link', ->
    mixpanel.track("Facebook Share")

  $(document).on 'show.bs.modal', '#modal-login-form', ->
    mixpanel.track("Signup Form Presented")