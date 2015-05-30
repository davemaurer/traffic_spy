class Client < ActiveRecord::Base
  attr_reader :url

  has_many :payloads
  validates_presence_of :identifier, :root_url
  validates :identifier, uniqueness: { case_sensitive: false }

  def take_path(path)
    path ? @url = (root_url + "/" + path) : @url = root_url
  end

  def url_payloads
    payloads.where(url: @url)
  end

  def longest_response
    url_payloads.maximum(:responded_in)
  end

  def shortest_response
    url_payloads.minimum(:responded_in)
  end

  def average_response
    url_payloads.average(:responded_in)
  end

  def http_verbs
    url_payloads.uniq.pluck(:request_type)
  end

  def popular_referrers
    url_payloads.group(:referred_by).order('count_referred_by desc').count(:referred_by).first(3)
  end

  def popular_browsers
    url_payloads.group(:browser).order('count_browser desc').count(:browser).first(3)
  end
end

