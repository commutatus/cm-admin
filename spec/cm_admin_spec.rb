# require 'cm_admin'
require 'pry'
require_relative 'spec_helper'


RSpec.describe CmAdmin::Configuration, type: :request do
  # it "has a version number" do
  #   expect(CmAdmin::VERSION).not_to be nil
  # end

  # it "does something useful" do
  #   expect(false).to eq(true)
  # end

  # it 'Check all included models' do
    # binding.pry
    # CmAdmin.config.included_models = [FileImport]
    # expect(CmAdmin.config.cm_admin_models.collect(&:name)).to eq(["FileImport", "Post"])
  # end


  it 'create a post' do
    visit('/admin/posts')
    click_link('Add')
    fill_in 'post[name]', with: 'Post name'
    fill_in 'post[title]', with: 'Post title'
    fill_in 'post[content]', with: 'Post content'
    click_button 'Save'
    # binding.pry

    # expect(page).to have_content('new post')
    # expect(page).to have_content('new post1')
  end

  it 'has correct input field names' do
    visit('/admin/posts')
    click_link('Add')
    expect(page).to have_content('Section heading')
    expect(page).to have_selector('label[for=post_Name]')
    expect(page).to have_selector("input#post_Name[name='post[name]']")
    expect(page).to have_selector('label[for=post_Title]')
    expect(page).to have_selector("input#post_title[name='post[title]']")
    expect(page).to have_selector('label[for=post_Content]')
    expect(page).to have_selector("input#post_content[name='post[content]']")
  end

  
end
