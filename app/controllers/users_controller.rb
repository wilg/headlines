class UsersController < ApplicationController

  def index
    @users = User.all.top.paginate(:page => params[:page], :per_page => 40)
  end

end
