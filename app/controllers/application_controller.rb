class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :redirect_if_old

  include VoteHelper

  def protect_api
    if request.format.to_sym == :json
      @api_key_user = User.find_by_api_key(params[:api_key])
      unless @api_key_user
        render json: {error: "No API key provided."}, status: :unauthorized
      else
        User.increment_counter(:api_requests, @api_key_user.id)
      end
    end
  end

  protected

  def redirect_if_old
    if request.host == 'headline-generator.herokuapp.com'
      redirect_to "http://www.headlinesmasher.com#{request.fullpath}", :status => :moved_permanently
    end
  end

end
