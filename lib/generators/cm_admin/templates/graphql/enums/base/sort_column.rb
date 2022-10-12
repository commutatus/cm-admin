module Types
  class Enums::Base::SortColumn < Types::BaseEnum
    description 'Possible values for sort column'

    value :created_at, 'Sort by created_at'
  end
end