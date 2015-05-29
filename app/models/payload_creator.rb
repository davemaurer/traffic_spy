require 'digest/sha1'
module TrafficSpy
  class PayloadCreator
    attr_accessor :status, :body

    def initialize(json, client)
      @status = 0
      @body = ""
      process(json, client)
    end

    def process(json, client)
      if registered?(client)
        make(json, client)
      else
        @status = 403
        @body = "URL not recognized"
      end
    end

    def registered?(client)
      Client.exists?(identifier: client.identifier) if client
    end

    def parse_json(json)
      JSON.parse(json) if json
    end

    def create_sha(string)
      Digest::SHA1.hexdigest(string) if string
    end

    def make(json, client)
      sha = create_sha(json)
      json ? data = parse_json(json) : data = {}
      payload = Payload.new({url: data["url"], sha:sha, client_id: client.id})
      payload.save ? @status = 200 : checker(payload, sha)
    end

    def checker(payload, sha)
      if payload.url == nil
        @status = 400
        @body = "Payload missing"
      elsif Payload.exists?(sha: sha)
        @status = 403
        @body = "Payload already received"
      end
    end

    # def webroot(payload)
    #   data = JSON.parse(payload)
    #   website = URI(data["url"])
    #   website.scheme + "://" + website.host
    # end
  end
end

