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
      if client.first
        Client.exists?(identifier: client.first.identifier)
      end
    end

    def parse_json(json)
      JSON.parse(json) if json
    end

    def create_sha(string)
      Digest::SHA1.hexdigest(string) if string
    end

    def make(json, client)
      sha = create_sha(json)
      data = parse_json(json)
      data = {} if data == nil
      payload = Payload.new({url: data["url"], sha:sha, client_id: client.first.id})
      if payload.save
        @status = 200
      else
        checker(payload, sha)
      end
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

