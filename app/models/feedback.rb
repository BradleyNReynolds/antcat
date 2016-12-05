# TODO remove `feedbacks.email_recipients`.

class Feedback < ActiveRecord::Base
  include Feed::Trackable

  belongs_to :user

  validates :comment, presence: true, length: { maximum: 10_000 }

  scope :pending_count, -> { where(open: true).count }
  scope :by_status_and_date, -> do
    order(<<-SQL.squish)
      CASE WHEN open = TRUE THEN (9999 + created_at)
      ELSE created_at END DESC
    SQL
  end
  scope :recently_created, ->(time_ago = 5.minutes.ago) {
    where('created_at >= ?', time_ago)
  }

  acts_as_commentable
  has_paper_trail
  tracked on: [:create, :destroy]

  def from_the_same_ip
    Feedback.where(ip: ip)
  end

  def closed?
    !open?
  end

  def close
    self.open = false
    save!
    create_activity :close_feedback
  end

  def reopen
    self.open = true
    save!
    create_activity :reopen_feedback
  end
end
