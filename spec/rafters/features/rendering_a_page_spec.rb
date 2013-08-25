require 'spec_helper'

feature "Rendering a page" do
  scenario "with components on it" do
    visit "/posts"
    page.should have_css(".posts")
  end
end
