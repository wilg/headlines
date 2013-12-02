class VotesController < ApplicationController

  def index
    @user = User.find_by_login(params[:user_id])
    @headlines = @user.voted_headlines_without_self.newest.paginate(:page => params[:page], :per_page => 40)
  end

end
