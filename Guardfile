guard 'spork' do
  watch('lib/rafters.rb')
  watch('Gemfile.lock')
  watch('spec/spec_helper.rb')
  watch(%r{features/dummy/})
  watch(%r{spec/support/})
end

guard :rspec, cli: "--drb" do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/rafters/(.+)\.rb$})             { |m| "spec/rafters/#{m[1]}_spec.rb" }
  watch(%r{^lib/rafters/(.*)/(.+)\.rb$})        { |m| "spec/rafters/#{m[1]}/#{m[2]}_spec.rb" }
  watch('spec/spec_helper.rb')                  { "spec" }

  # Dummy app
  watch(%r{^spec/dummy/app/(.+)\.rb$})                           { |m| "spec/rafters/features" }
  watch(%r{^spec/dummy/app/(.*)(\.erb|\.haml|\.slim)$})          { |m| "spec/rafters/features" }
  watch(%r{^spec/dummy/app/controllers/(.+)_(controller)\.rb$})  { |m| "spec/rafters/features" }
end
