module TrafficSpy
  class Dashboard
    attr_reader :client
    def initialize(client)
      @client = client
    end

    def view
      @client ? :dashboard : :error
    end

    def sorted_urls
      @client.payloads.group(:url).order('count_url desc').count(:url)
    end

  end
end
