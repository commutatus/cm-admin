class Post < ApplicationRecord
	validates :content, presence: true
	cm_admin do
	  actions only: []
	  cm_index do
	    page_title 'Post'
	    page_description 'View all your Posts here'

	    column :id
	    column :name
	    column :title
	    column :content
	  end

	  cm_new page_title: 'Add Post', page_description: 'Enter all details to add post' do
      form_field :name, input_type: :string, label: 'Name'
      form_field :title, input_type: :string, label: 'Title'
      form_field :content, input_type: :string, label: 'Content'
    end
	end
end

