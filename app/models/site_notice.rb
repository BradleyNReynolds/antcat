class SiteNotice < ApplicationRecord
  include Trackable
  include SendsNotifications

  belongs_to :user

  validates :user, presence: true
  validates :message, presence: true
  validates :title, presence: true, length: { maximum: 70 }

  scope :order_by_date, -> { order(created_at: :desc) }

  acts_as_commentable
  acts_as_readable on: :created_at
  has_paper_trail
  tracked on: :all, parameters: proc { { title: title } }
  enable_user_notifications_for :message
end