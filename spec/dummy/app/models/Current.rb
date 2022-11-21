class Current < ActiveSupport::CurrentAttributes
    attribute :user
    attribute :request
    attribute :ip_address

    def user=(user)
      super
    end
end 