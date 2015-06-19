module TrafficSpy
  class ClientCreator
    attr_accessor :status, :body

    def initialize(params)
      make(params)
    end

    def make(params)
      client = Client.new({identifier: params[:identifier], root_url: params[:rootUrl]})
      if client.save
        @status = 200
        @body = {identifier:"#{client.identifier}"}.to_json
      else
        result = checker(client)
        @status = result.first
        @body = result.last
      end
    end

    def checker(client)
      result = [400]
      if Client.exists?(identifier: client.identifier)
        result = [403, "Identifier already exists"]
      elsif client.identifier == nil && client.root_url == nil
        result << "Please enter an identifier and rootUrl"
      elsif client.root_url == nil
        result << "Make sure you enter a rootUrl"
      else
        result << "Make sure you enter an identifier"
      end
      result
    end
  end
end
