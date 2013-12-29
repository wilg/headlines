class CommentsController < ApplicationController

  def create
    @headline = Headline.find(params[:headline_id])
    @comment = @headline.comments.build(comment_params)
    @comment.user = current_user
    @comment.save
  end

  def destroy
    @comment = Comment.find(params[:id])
    if @comment.user == current_user
      @comment.destroy!
    end
    redirect_to @comment.headline
  end

  def index
    @user = User.find_by_login(params[:user_id])
    if @user
      @comments = @user.comments
    else
      @comments = Comment.all
    end
    @comments = @comments.order("created_at desc").paginate(:page => params[:page], :per_page => 40)
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end

end
