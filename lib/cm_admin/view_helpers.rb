module CmAdmin
  module ViewHelpers
    Dir[File.expand_path("view_helpers", __dir__) + "/*.rb"].each  { |f| require f }

    include PageInfoHelper
    include NavigationHelper
    include FormHelper
    include ColumnFieldHelper
  end
end
