class UsersController < ApplicationController
  before_action :authenticate_editor, except: [:index]
  before_action :set_user, only: [:show]

  def index
    @users = User.order_by_name
  end

  def show
    @recent_user_activities = @user.activities.most_recent 5
    @recent_user_comments = @user.comments.most_recent 5
  end

  def emails
    @editor_emails = User.editors.order_by_name.as_angle_bracketed_emails
    @non_editor_emails = User.non_editors.order_by_name.as_angle_bracketed_emails
    @all = "#{@editor_emails}, #{@non_editor_emails}"
  end

  private
    def set_user
      @user = User.find params[:id]
    end
end
