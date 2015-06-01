module TrafficSpy
  class Payload < ActiveRecord::Base
    belongs_to :client
    validates_presence_of :url,
                          :sha,
                          :client_id,
                          :responded_in,
                          :resolution,
                          :browser,
                          :platform,
                          :request_type,
                          :referred_by,
                          :event_name,
                          :requested_at
    validates :sha, uniqueness: true
  end
end
