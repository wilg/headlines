module UsersHelper

  def user_data
    return {} unless current_user.present?
    {
      username: current_user.login,
      created: current_user.created_at,
      karma: current_user.karma,
      comments: current_user.comments_count,
      votes: current_user.votes_count,
      signed_in: current_user.current_sign_in_at,
      newly_registered: flash[:newly_registered] ? 'true' : nil
    }
  end

end
