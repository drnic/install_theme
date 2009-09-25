require 'rubygems'
require 'hoe'
require 'fileutils'
require './lib/convert_theme'

Hoe.plugin :newgem

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec 'convert_theme' do
  self.developer 'Dr Nic Williams', 'drnicwilliams@gmail.com'
  # self.extra_deps         = [['activesupport','>= 2.0.2']]
end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
remove_task :default
task :default => [:spec]
