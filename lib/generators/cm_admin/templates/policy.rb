class CmAdmin::<%= class_name %>Policy < ApplicationPolicy
  <%- cm_model = CmAdmin::Model.find_by({name: class_name}) %>
  <%- raise "cm_admin is not defined inside #{class_name} model" unless cm_model.present? %>
  <%- available_action_names = (cm_model.available_actions.map{|action| action.name}.uniq - ['custom_action', 'new', 'edit']) %>
  <%- available_action_names.each do |action_name| %>
  def <%= action_name %>?
    <%= CmAdmin.authorized_roles.map {|role| "@user.#{role}" }.join(' && ') %>
  end
  <% end %>
end