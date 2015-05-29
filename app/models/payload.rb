class Payload < ActiveRecord::Base
  belongs_to :client
  validates_presence_of :url, :sha
  validates :sha, uniqueness: true
end
