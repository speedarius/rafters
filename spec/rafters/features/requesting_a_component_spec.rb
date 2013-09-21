require 'spec_helper'

feature "Requesting a component" do
  scenario "from a page" do
    visit "/posts?component=heading&options[as]=title&options[settings][title]=Title%20Component"
    expect(page).to have_content("Title Component")
  end
end
