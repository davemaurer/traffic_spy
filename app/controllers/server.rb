require 'uri'
module TrafficSpy
  class Server < Sinatra::Base
    get '/' do
      erb :index
    end

    not_found do
      erb :error
    end

    post '/sources' do
      result = TrafficSpy::ClientCreator.new(params)
      status  result.status
      body    result.body
    end

    post '/sources/:id/data' do |id|
      client = Client.find_by(identifier: id)
      result = TrafficSpy::PayloadCreator.new(params[:payload], client)
      status  result.status
      body    result.body
    end

    get '/sources/:id' do |id|
      client = Client.find_by(identifier: id)
      @data = Dashboard.new(client)
      erb @data.view
    end

    get '/sources/:id/urls/:path' do |id, path|
      @client = Client.find_by(identifier: id)
      @client.take_path(path)
      erb :url
    end

    get '/sources/:id/events/:event' do |id, event|
      client = Client.find_by(identifier: id)
      erb :event
    end

    get '/sources/:id/events' do |id|
      erb :events
    end
  end
end
