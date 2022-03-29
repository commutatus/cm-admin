class CmAdmin::<%= class_name %>Policy < ApplicationPolicy
  def initialize(user, record)
    @user = user
    @record = record
  end
  <%- available_action_names = (CmAdmin::Model.find_by({name: class_name}).available_actions.map{|action| action.name}.uniq - ["custom_action"]) %>
  <%- available_action_names.each do |action_name| %>
  def <%= action_name %>?
    <%= CmAdmin.authorized_roles.map {|role| "@user.#{role}" }.join(' && ') %>
  end
  <% end %>
end