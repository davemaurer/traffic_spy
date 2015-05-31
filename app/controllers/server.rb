require 'uri'
module TrafficSpy
  class Server < Sinatra::Base

    helpers do
      def protected!
        if ENV["RACK_ENV"] == 'development'
          return if authorized?
          headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
          halt 401, "Not authorized\n"
        end
      end

      def authorized?
        @auth ||=  Rack::Auth::Basic::Request.new(request.env)
        @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == [@client.identifier, @client.identifier + 'pass']
      end

      def json_dashboard
        data = []
        data << @client.sorted_urls
        data << @client.url_avg_response_times
        data << @client.resolution_breakdown
        data << @client.browser_breakdown
        data << @client.platform_breakdown
        data << @client.events
        data.to_json
      end

      def get_client(id)
        @client = TrafficSpy::Client.find_by(identifier: id)
      end
    end

    get '/?' do
      erb :index
    end

    not_found do
      @error = "404 : Page not found"
      erb :error
    end

    post '/sources/?' do
      result = TrafficSpy::ClientCreator.new(params)
      status  result.status
      body    result.body
    end

    post '/sources/:id/data/?' do |id|
      get_client(id)
      result = TrafficSpy::PayloadCreator.new(params[:payload], @client)
      status  result.status
      body    result.body
    end

    get '/sources/:id/?' do |id|
      id_path = id.split(".")
      redirect to ("/sources/#{id_path.first}/json") if id_path.last == "json"
      get_client(id)
      if @client
        protected!
        erb :dashboard
      else
        @error = "The Identifier '#{id}' does not exist."
        erb :error
      end
    end

    get '/sources/:id/urls/*' do |id, splat|
      get_client(id)
      @client.take_path(splat) if @client
      if @client && @client.path_exists?
        protected!
        erb :url
      elsif @client
        @error = "The path '/#{splat}' has not been requested"
        erb :error
      else
        @error = "The Identifier '#{id}' does not exist."
        erb :error
      end
    end

    get '/sources/:id/events/:event/?' do |id, event|
      get_client(id)
      @client.take_event(event) if @client
      if @client && @client.event_exists?
        protected!
        erb :event
      elsif @client
        @error = "The event '#{event}' has not been defined"
        @event_link = "/sources/#{id}/events"
        erb :error
      else
        @error = "The Identifier '#{id}' does not exist."
        erb :error
      end
    end

    get '/sources/:id/events/?' do |id|
      get_client(id)
      if @client && @client.has_events?
        erb :events
      elsif @client
        @error = "No Events have been defined"
        erb :error
      else
        @error = "The Identifier '#{id}' does not exist."
        erb :error
      end
    end

    get '/sources/:id/urls/?' do |id|
      get_client(id)
      if @client
        protected!
        erb :urls
      else
        @error = "The Identifier '#{id}' does not exist."
        erb :error
      end
    end

    get '/sources/:id/json' do |id|
      get_client(id)
      if @client
        protected!
        content_type :json
        json_dashboard
      else
        @error = "The Identifier '#{id}' does not exist."
        erb :error
      end
    end

    get '/sources/:id/urls.json' do |id|
      get_client(id)
      content_type :json
      if @client
        @client.sorted_urls.to_json
      else
        @error = "The Identifier '#{id}' does not exist."
        erb :error
      end
    end

    get '/sources/:id/events.json' do |id|
      get_client(id)
      content_type :json
      if @client
        @client.events.to_json
      else
        @error = "The Identifier '#{id}' does not exist."
        erb :error
      end
    end
  end
end
