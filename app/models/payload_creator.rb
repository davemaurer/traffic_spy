require 'digest/sha1'
require 'useragent'

module TrafficSpy
  class PayloadCreator
    attr_accessor :status, :body

    def initialize(json, client)
      # @status = 0
      # @body = ""
      process(json, client)
    end

    def process(json, client)
      if registered?(client)
        create_payload(json, client)
      else
        @status = 403
        @body = "URL not recognized"
      end
    end

    def registered?(client)
      Client.exists?(identifier: client.identifier) if client
    end

    def parse_json(json)
      JSON.parse(json) #check the json here
    end

    def create_sha(string)
      Digest::SHA1.hexdigest(string) if string
    end

    def create_payload(json, client)
      sha = create_sha(json)
      json ? data = parse_json(json) : data = {}
      user_agent = UserAgent.parse(data["userAgent"])
      payload = TrafficSpy::Payload.new(url: data["url"],
                            sha:sha,
                            client_id: client.id,
                            responded_in: data["respondedIn"],
                            resolution: "#{data['resolutionWidth']} x #{data['resolutionHeight']}",
                            browser: user_agent.browser,
                            platform: user_agent.platform,
                            requested_at: data["requestedAt"],
                            request_type: data["requestType"],
                            referred_by: data["referredBy"],
                            event_name: data["eventName"]
                            )
      payload.save ? @status = 200 : checker(payload, sha)
    end

    def checker(payload, sha)
      if payload.url == nil
        @status = 400
        @body = "Payload missing"
      elsif TrafficSpy::Payload.exists?(sha: sha)
        @status = 403
        @body = "Payload already received"
      end
    end
  end
end

