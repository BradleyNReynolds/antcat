class User < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include Feed::Trackable

  has_many :comments
  has_many :activities, class_name: "Feed::Activity"

  validates :name, presence: true

  scope :order_by_name, -> { order(:name) }
  scope :editors, -> { where(can_edit: true) }
  scope :non_editors, -> { where(can_edit: [false, nil]) } # TODO only allow true/false?
  scope :feedback_emails_recipients, -> { where(receive_feedback_emails: true) }
  scope :as_angle_bracketed_emails, -> { all.map(&:angle_bracketed_email).join(", ") }

  acts_as_reader
  devise :database_authenticatable, :recoverable, :registerable,
    :rememberable, :trackable, :validatable, :invitable
  tracked on: :create, parameters: ->(user) do { user_id: user.id } end

  def self.current
    RequestStore.store[:current_user]
  end

  def self.current=(user)
    RequestStore.store[:current_user] = user
  end

  def can_approve_changes?
    can_edit?
  end

  def can_review_changes?
    can_edit?
  end

  def angle_bracketed_email
    %Q["#{name}" <#{email}>]
  end
end
