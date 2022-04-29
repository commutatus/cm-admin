class CmAdmin::<%= class_name %>Policy < ApplicationPolicy
  <%- available_action_names = (cm_model.available_actions.map{|action| action.name}.uniq - ['custom_action', 'new', 'edit']) %>
  <%- available_action_names.each do |action_name| %>
  def <%= action_name %>?
    <%= CmAdmin.authorized_roles.map {|role| "@user.#{role}" }.join(' && ') %>
  end
  <% end %>
end