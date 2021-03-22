module CmAdmin
  DEFAULT_ACTIONS = {
    index: {
      verb: :get
    },
    show: {
      verb: :get
    },
    new: {
      verb: :get
    },
    create: {
      verb: :post
    },
    edit: {
      verb: :get
    },
    update: {
      verb: :put
    },
    destroy: {
      verb: :delete
    }
  }
end
