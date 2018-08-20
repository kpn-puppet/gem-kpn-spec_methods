# Static functions previously located in spec_helper_acceptance_methods.rb

module KpnSpecMethods
  # Fetches all modules from the fixtures file
  def self.clone_dependent_modules
    fixtures = YAML.load_file('.fixtures.yml')['fixtures']
    fixtures['repositories'].each do |module_name, value|
      ssh_link =
        if value.is_a?(Hash)
          value['repo']
        else
          value
        end
      ref =
        if value.is_a?(Hash) and value.has_key?('ref')
          value['ref']
        else
          'master'
        end
      system("git clone --branch #{ref} #{ssh_link} spec/fixtures/modules/#{module_name}")
    end
  end

  # Standard way to copy modules by individual file transfer
  def self.install_dependent_modules
    fixtures = YAML.load_file('.fixtures.yml')['fixtures']
    fixtures['repositories'].each do |module_name, value|
      # Check metadata.json and only copy modules that support target OS
      copy_module = true
      if File.file?("./spec/fixtures/modules/#{module_name}/metadata.json")
        metadata = JSON.parse(File.open("./spec/fixtures/modules/#{module_name}/metadata.json").read)
        if metadata.key?("operatingsystem_support") and metadata["operatingsystem_support"].select { |os| os["operatingsystem"].downcase == fact('osfamily').downcase }.count == 0
          copy_module = false
        end
      end
      if copy_module
        copy_module_to(hosts, :source => "./spec/fixtures/modules/#{module_name}", :module_name => module_name)
      end
    end
  end

  def self.log_msg(msg)
    default.logger.notify "# #{msg}"
  end

  def self.log_title(msg)
    default.logger.notify "###### #{msg} ######"
  end

  # Quicker way to copy modules by archiving
  def self.compress_copy_dependent_modules
    # Determine OS family for tar or zip usage
    os = host_inventory['facter']['kernel']
    if os == 'windows'
      compress_command = 'cd spec/fixtures/modules/; /usr/bin/zip -qr ../../../archive/modules.zip * -x *.git* ;cd -'
      extract_command = 'powershell.exe -nologo -noprofile -command "& { Add-Type -A \'System.IO.Compression.FileSystem\'; [IO.Compression.ZipFile]::ExtractToDirectory(\'C:\ProgramData\PuppetLabs\code\modules\modulesarchive\modules.zip\', \'C:\ProgramData\PuppetLabs\code\modules\\\'); }"'
    elsif os == 'Linux'
      compress_command = "cd spec/fixtures/modules/; /usr/bin/tar -cf ../../../archive/modules.tar * --exclude='*.git'; cd -"
      extract_command = 'tar -xf /etc/puppetlabs/code/modules/modulesarchive/modules.tar -C /etc/puppetlabs/code/modules/; rm -rf /etc/puppetlabs/code/modules/modulesarchive'
    else
      # Switch to old transfer if os is not found
      print "\033[31m Warning: OS family fact could not be determined for module copying \n"
      print "\033[31m Switching to sluggish old transfer... \n"
      install_dependent_modules
      return
    end

    # Archive the cloned modules
    system('mkdir archive') unless File.directory?('archive')
    system(compress_command)

    # Copy the archive to machine
    copy_module_to(hosts, source: 'archive', module_name: 'modulesarchive') if File.file?('archive/modules.tar') || File.file?('archive/modules.zip')
    hosts.each do |host|
      on host, extract_command
    end
  end
end
