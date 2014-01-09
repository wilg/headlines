class VotesController < ApplicationController

  def index
    @user = User.find_by_login(params[:user_id])
    @headlines = default_pagination @user.voted_headlines_without_self.newest
  end

end
