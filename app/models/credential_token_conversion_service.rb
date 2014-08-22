require 'app/models/credential_token'
require 'oauth2/access_token'

class CredentialTokenConversionService
  def self.credential_token_from_oauth2_access_token(oauth2_access_token)
    token_string  = oauth2_access_token.token
    metadata_hash = oauth2_access_token.to_hash.symbolize_keys

    CredentialToken.new(
      :token      => token_string,
      :metadata   => metadata_hash
    )
  end

  def self.oauth2_access_token_from_credential_token(credential_token, client)
    token_string = credential_token.token.to_s

    OAuth2::AccessToken.from_hash(client, credential_token.metadata.dup)
  end
end
