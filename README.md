# kpn_spec_methods

This gem contains the spec acceptance helper methods that were previously located in spec_helper_acceptance_methods.rb

TODO: rspec test for this gem

## Dependencies

This gem has no gem dependencies.

## Installation

Add this line to your spec_helper_acceptance.rb:

```ruby
require 'kpn_spec_methods'
```

Make sure the gem is installed:

    $ gem install kpn_spec_methods

## Usage

This gem contains 5 functions:
- clone_dependent_modules
- install_dependent_modules
- log_msg
- log_title
- compress_copy_dependent_modules

### clone_dependent_modules
A function that fetches all modules from the fixtures file.

Insert the function KpnCompressCopyModules.clone_dependent_modules to the spec_helper_acceptance.rb in place of the clone_dependent_modules function.

Example from profile_windows in spec_helper_acceptance.rb
```ruby
require_relative 'versions.rb'
require 'kpn_compress_copy_modules'

UNSUPPORTED_PLATFORMS = ['RedHat', 'Debian', 'Solaris', 'AIX']

unless ENV['RS_PROVISION'] == 'no' or ENV['BEAKER_provision'] == 'no'

  # Install Puppet Enterprise Agent
  run_puppet_install_helper

  # Clone module dependencies
  KpnCompressCopyModules.clone_dependent_modules
end
```

### install_dependent_modules
A function that copies all modules file-by-file to the host. Use this function only when compress_copy_dependent_modules does not work.

Insert the function KpnCompressCopyModules.install_dependent_modules to the spec_helper_acceptance.rb in place of the install_dependent_modules function.

Example from profile_windows in spec_helper_acceptance.rb
```ruby
RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install dependent modules
    KpnCompressCopyModules.install_dependent_modules

    # Install module
    puppet_module_install(:source => proj_root, :module_name => 'profile_windows')

```

### log_title
Function to print a title while running a test.

Example from profile_windows in spec_helper_acceptance.rb
```ruby
  # Set routes back to dev stations and Jenkins
  KpnSpecMethods.log_title("Setup Network Routes for Development and Jenkins")
```

### log_msg
Function to print a message while running a test.

Example from profile_windows in spec_helper_acceptance.rb
```ruby
  KpnSpecMethods.log_msg("Message here.")
```

### compress_copy_dependent_modules
A function used to archive all dependent modules and copy these to hosts as a single file, instead of copying each file with a seperate command. This significantly lowers the time needed for a beaker test when a module has many dependencies.

Insert the function KpnCompressCopyModules.compress_copy_dependent_modules to the spec_helper_acceptance.rb in place of the install_dependent_modules function.

Example from profile_linux in spec_helper_acceptance.rb
```ruby
RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do

    # Copy hiera
    hierarchy = [
      '%{facts.os.family}-%{facts.os.release.major}',
      'common',
    ]
    write_hiera_config(hierarchy)
    copy_hiera_data('./spec/hieradata/beaker')

    # Install dependent modules
    KpnSpecMethods.compress_copy_dependent_modules

    # Install module
    puppet_module_install(:source => proj_root, :module_name => 'profile_linux')
```