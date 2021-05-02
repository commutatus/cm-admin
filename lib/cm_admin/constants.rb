module CmAdmin
  DEFAULT_ACTIONS = {
    index: {
      verb: :get,
      path: 'index'
    },
    show: {
      verb: :get,
      path: ':id'
    },
    new: {
      verb: :get,
      path: 'new'
    },
    create: {
      verb: :post,
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
    export: {
      verb: :get,
      path: 'export'
    }
  }
  REJECTABLE_FIELDS = %w(id created_at updated_at)
end
