class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  include ActiveStorage::Reflection::ActiveRecordExtensions
  ActiveRecord::Reflection.singleton_class.prepend(ActiveStorage::Reflection::ReflectionExtension)
  include ActiveStorage::Attached::Model
end
