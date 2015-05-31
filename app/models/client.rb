module TrafficSpy
  class Client < ActiveRecord::Base
    attr_reader :url, :event

    has_many :payloads
    validates_presence_of :identifier, :root_url
    validates :identifier, uniqueness: { case_sensitive: false }

    def sorted_urls
      payloads.group(:url).order('count_url desc').count(:url)
    end

    def resolution_breakdown
      payloads.group(:resolution).order('count_resolution desc').count(:resolution)
    end

    def path(url)
      uri = URI(url)
      "/sources/#{identifier}/urls#{uri.path}"
    end

    def event_path(event)
      "/sources/#{identifier}/events/#{event}"
    end

    def url_avg_response_times
      payloads.group(:url).order('average_responded_in desc').average(:responded_in)
    end

    def browser_breakdown
      payloads.group(:browser).order('count_browser desc').count(:browser)
    end

    def platform_breakdown
      payloads.group(:platform).order('count_platform desc').count(:platform)
    end

    def events
      payloads.group(:event_name).order('count_event_name desc').count(:event_name)
    end

    def take_path(path)
      path ? @url = (root_url + "/" + path) : @url = root_url
    end

    def path_exists?
      url_payloads.exists?(url: @url)
    end

    def longest_response
      url_payloads.maximum(:responded_in)
    end

    def shortest_response
      url_payloads.minimum(:responded_in)
    end

    def average_response
      url_payloads.average(:responded_in).round(2)
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

    def popular_platforms
      url_payloads.group(:platform).order('count_platform desc').count(:platform).first(3)
    end

    def take_event(event)
      @event = event
    end

    def event_exists?
      payloads.exists?(event_name: @event)
    end

    def event_counter
      event_payloads.count
    end

    def hourly_breakdown
      datetimes = event_payloads.pluck(:requested_at)
      hours = datetimes.map(&:hour).sort
      hours.each_with_object(Hash.new(0)) { |hour, hash| hash[hour] += 1 }
    end

    private

    def url_payloads
      payloads.where(url: @url)
    end

    def event_payloads
      payloads.where(event_name: @event)
    end
  end
end
