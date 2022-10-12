CmAdmin.configure do |config|
  # Sets the default layout to be used for admin
  config.layout = 'admin'
  # config.authorized_roles = [:super_admin?]
  config.included_models = [FileImport]
end