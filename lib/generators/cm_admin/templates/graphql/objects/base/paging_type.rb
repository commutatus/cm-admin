module Types::Objects::Base
  class PagingType < Types::BaseObject
    graphql_name 'PagingType'
    field :current_page, Integer, null: true
    field :total_items, Integer, null: true
    field :total_pages, Integer, null: true
    field :total_count, Integer, null: true
  end
end
