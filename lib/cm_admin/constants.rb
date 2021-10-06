module CmAdmin
  DEFAULT_ACTIONS = {
    index: {
      verb: :get,
      path: '/'
    },
    new: {
      verb: :get,
      path: 'new'
    },
    show: {
      verb: :get,
      path: ':id'
    },
    create: {
      verb: :post,
      path: '/'
    },
    edit: {
      verb: :get,
      path: ':id/edit'
    },
    update: {
      verb: :patch,
      path: ':id'
    },
    destroy: {
      verb: :delete,
      path: ':id'
    },
    custom_action: {
      verb: :post
    }
  }
  REJECTABLE_FIELDS = %w(id created_at updated_at)
end
