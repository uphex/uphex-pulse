require 'active_record'
require 'json'

class CredentialToken < ActiveRecord::Base
  belongs_to :stream
  has_many :stream_credentials
  has_many :streams, :through => :stream_credentials

  validates :token, :presence => true
  validates :metadata, :presence => true
  validate :metadata_formatted_as_json

  after_initialize do
    self.metadata ||= {}
  end

  def metadata_formatted_as_json
    begin
      !!JSON.parse(self.metadata)
    rescue
      false
    end
  end
end
