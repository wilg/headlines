class UsersController < ApplicationController

  def index
    if params[:timeframe] == "this_month"
      @users = User.with_karma_for_timeframe(1.month).limit(25)
    elsif params[:timeframe] == "this_week"
      @users = User.with_karma_for_timeframe(1.week).limit(25)
    elsif params[:timeframe] == "today"
      @users = User.with_karma_for_timeframe(1.day).limit(25)
    else
      @users = User.all.top.paginate(:page => params[:page], :per_page => 25)
    end
  end

  def show
    @user = User.find_by_login(params[:id])
    raise ActionController::RoutingError.new('Not Found') unless @user
  end

end
