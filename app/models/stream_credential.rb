require 'active_record'

class StreamCredential < ActiveRecord::Base
  belongs_to :stream
  belongs_to :credential_token
end
