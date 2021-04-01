module CmAdmin
  DEFAULT_ACTIONS = [
    {
      action_name: :index,
      http_method: :get,
      route_fragment: '/'
    },
    {
      action_name: :show,
      http_method: :get,
      route_fragment: '/:id'
    },
    {
      action_name: :new,
      http_method: :get,
      route_fragment: '/new'
    },
    {
      action_name: :create,
      http_method: :post,
      route_fragment: '/'
    },
    {
      action_name: :update,
      http_method: :put,
      route_fragment: '/:id/update'
    },
    {
      action_name: :destroy,
      http_method: :delete,
      route_fragment: '/:id/destroy'
    }
  ]
end
