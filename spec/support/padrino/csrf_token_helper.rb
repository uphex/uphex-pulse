module CSRFTokenHelper
  def set_csrf_token(token = 'token')
    header('X-CSRF-Token', token)
    env('rack.session', :csrf => token)
  end
end

RSpec.configure do |c|
  c.include CSRFTokenHelper
end
