require 'uri'

module TrafficSpy
  class Dashboard
    attr_reader :client

    def initialize(client)
      @client = client
    end

    def identifier
      @client.identifier
    end

    def view
      @client ? :dashboard : :no_identifier
    end

    def sorted_urls
      @client.payloads.group(:url).order('count_url desc').count(:url)
    end

    def resolution_breakdown
      @client.payloads.group(:resolution).order('count_resolution desc').count(:resolution)
    end

    def path(url)
      uri = URI(url)
      "/sources/#{@client.identifier}/urls#{uri.path}"
    end

    def event_path(event)
      "/sources/#{@client.identifier}/events/#{event}"
    end

    def url_avg_response_times
      @client.payloads.group(:url).order('average_responded_in desc').average(:responded_in)
    end

    def browser_breakdown
      @client.payloads.group(:browser).order('count_browser desc').count(:browser)
    end

    def platform_breakdown
      @client.payloads.group(:platform).order('count_platform desc').count(:platform)
    end

    def events
      @client.payloads.group(:event_name).order('count_event_name desc').count(:event_name)
    end
  end
end
