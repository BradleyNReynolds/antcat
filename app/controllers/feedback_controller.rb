class FeedbackController < ApplicationController
  include ActionView::Helpers::DateHelper

  before_filter :authenticate_editor, only: [:index]
  before_filter :set_feedback, only: [:show, :close, :reopen]

  invisible_captcha only: [:create], honeypot: :work_email, on_spam: :on_spam

  def index
    @feedbacks = Feedback.order(id: :desc).paginate(page: params[:page], per_page: 10)
  end

  def show
    @new_comment = Comment.build_comment @feedback, current_user
  end

  def create
    @feedback = Feedback.new feedback_params
    @feedback.ip = request.remote_ip
    render_unprocessable and return if maybe_rate_throttle

    if current_user
      @feedback.user = current_user
      @feedback.name = current_user.name
      @feedback.email = current_user.email
    end

    respond_to do |format|
      if @feedback.save
        send_feedback_email
        format.json do
          json = { feedback_success_callout: feedback_success_callout }
          render json: json, status: :created
        end
      else
        format.json do
          render_unprocessable
        end
      end
    end
  end

  def close
    @feedback.close
    redirect_to @feedback, notice: "Successfully closed feedback item."
  end

  def reopen
    @feedback.reopen
    redirect_to @feedback, notice: "Successfully re-opened feedback item."
  end

  private
    def set_feedback
      @feedback = Feedback.find(params[:id])
    end

    def on_spam
      @feedback = Feedback.new feedback_params
      @feedback.errors.add :hmm, "you're not a bot are you? Feedback not sent. Email us?"
      render_unprocessable
    end

    def maybe_rate_throttle
      return if current_user # logged-in users are never throttled

      max_feedbacks_in_timespan = 3
      timespan = 5.minutes.ago

      if @feedback.from_the_same_ip.recently_created(timespan)
          .count >= max_feedbacks_in_timespan

        @feedback.errors.add :rate_limited, <<-ERROR_MSG
          you have already posted #{max_feedbacks_in_timespan} feedbacks in the last
          #{time_ago_in_words Time.at(timespan)}. Thanks for that! Please wait for
          a few minutes while we are trying to figure out if you are a bot...
        ERROR_MSG
      end
    end

    def render_unprocessable
      render json: @feedback.errors, status: :unprocessable_entity
    end

    def feedback_success_callout
      render_to_string partial: "feedback_success_callout",
        locals: { feedback_id: @feedback.id }
    end

    def send_feedback_email
      FeedbackMailer.feedback_email(@feedback).deliver_now
    end

    def feedback_params
      params.require(:feedback)
        .permit :comment, :name, :email, :user, :page
    end
end
