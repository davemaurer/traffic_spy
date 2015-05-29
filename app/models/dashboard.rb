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

    def path(url)
      uri = URI(url)
      uri.path
      "/sources/#{@client.identifier}/urls#{uri.path}"
    end
  end
end
