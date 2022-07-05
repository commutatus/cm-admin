class Current < ActiveSupport::CurrentAttributes
  attribute :user, :request_id, :user_agent, :ip_address

  resets { Time.zone = nil }

  def user=(user)
    super
  end
end