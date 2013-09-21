require 'spec_helper'

feature "Rendering a page" do
  scenario "with components on it" do
    visit "/posts"
    expect(page).to have_css(".posts")
  end
end
