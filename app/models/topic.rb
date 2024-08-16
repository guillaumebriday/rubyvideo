class Topic < ApplicationRecord
  include Sluggable

  slug_from :name

  has_many :talk_topics
  has_many :talks, through: :talk_topics

  # validations
  validates :name, presence: true, uniqueness: true

  # normalize attributes
  normalizes :name, with: ->(name) { name.squish }

  # scopes
  scope :with_talks, -> { joins(:talks).distinct }

  # enums
  enum :status, %w[pending approved rejected].index_by(&:itself)

  def self.create_from_list(topics, status: :pending)
    topics.map do |topic|
      Topic.find_or_create_by(name: topic).tap do |topic|
        topic.update(status: status)
      end
    end.uniq
  end
end