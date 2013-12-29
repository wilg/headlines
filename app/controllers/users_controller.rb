class UsersController < ApplicationController

  def index
    @users = User.all.top.paginate(:page => params[:page], :per_page => 25)
  end

  def show
    @user = User.find_by_login(params[:id])
  end

end
