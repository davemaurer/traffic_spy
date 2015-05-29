class Client < ActiveRecord::Base
  attr_reader :url

  has_many :payloads
  validates_presence_of :identifier, :root_url
  validates :identifier, uniqueness: { case_sensitive: false }

  def take_path(path)
    path ? @url = (root_url + "/" + path) : @url = root_url
  end

  def longest_response
    payloads.where(url: @url).maximum(:responded_in)
  end

  def shortest_response
    payloads.where(url: @url).minimum(:responded_in)
  end

  def average_response
    payloads.where(url: @url).average(:responded_in)
  end

  def http_verbs
    payloads.where(url: @url).uniq.pluck(:request_type)
  end
end

