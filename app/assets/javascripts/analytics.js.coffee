$ ->

  username = $('body').data('username')
  mixpanel.identify(username) if username?

  $(document).on 'click', '.twitter-share-link', ->
    mixpanel.track("Twitter Share")

  $(document).on 'click', '.facebook-share-link', ->
    mixpanel.track("Facebook Share")

  $(document).on 'show.bs.modal', '#modal-login-form', ->
    mixpanel.track("Signup Form Presented")