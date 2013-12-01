class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :redirect_if_old

  include VoteHelper

  protected

  def redirect_if_old
    if request.host == 'headline-generator.herokuapp.com'
      redirect_to "http://www.headlinesmasher.com#{request.fullpath}", :status => :moved_permanently
    end
  end

end
