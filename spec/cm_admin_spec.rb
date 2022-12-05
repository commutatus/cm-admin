# require 'cm_admin'
require 'pry'
require_relative 'spec_helper'


RSpec.describe CmAdmin::Configuration, type: :request do
  

  it 'Visit posts page and add post' do
    visit('/admin/posts')
    click_link('Add')
    fill_in 'post[name]', with: 'Welcome post'
    fill_in 'post[content]', with: 'Details of onboarding'
    click_button 'Save'
  end

  it 'create post and go to post details page' do
    visit('/admin/posts')
    click_link('Add')
    fill_in 'post[name]', with: 'Welcome post'
    fill_in 'post[content]', with: 'Details of onboarding'
    click_button 'Save'

    expect(page).to have_content('Welcome post')
    expect(page).to have_content('Details of onboarding')
  end

  it 'Delete post ' do
    @post = Post.create(name: "new blog post", content: "blog post details")
    visit("/admin/posts/#{@post.id}")
    visit post_destroy_path(@post.id)
  end

  
end
