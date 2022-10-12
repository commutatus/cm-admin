module Types
  class Enums::Base::SortDirection < Types::BaseEnum
    description 'Possible values for sort direction'

    value :asc, 'Sort by ascending'
    value :desc, 'Sort by descending'
  end
end