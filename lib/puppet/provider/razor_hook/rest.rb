require File.join(File.dirname(__FILE__), '..', 'razor_rest')

Puppet::Type.type(:razor_hook).provide :rest, :parent => Puppet::Provider::Rest do
  desc "REST provider for Razor hook"

  mk_resource_methods

  def flush
    if @property_flush[:ensure] == :absent
      delete_hook
      return
    end

    if @property_flush[:ensure] == :present
      create_hook
      return
    end

    update_hook
  end

  def self.instances
    get_objects(:hooks).collect do |object|
      new(object)
    end
  end

  # TYPE SPECIFIC
  def self.get_object(name, url)
    # Trick puppet telling it that the actual resource status is the status that should
    # be if ignore_changes is present, this will avoid that the resource is modified when it's
    # configuration changes. Example taken from exec's resource returns property
    # https://github.com/puppetlabs/puppet/blob/67ad21b64237eb4f808844bdaa3c2b0e4cdef95c/lib/puppet/type/exec.rb#L81
    if resource[:ignore_changes]
      return self.should
    else
      responseJson = get_json_from_url(url)

      return {
        :name           => responseJson['name'],
        :hook_type      => responseJson['hook_type'],
        :configuration  => responseJson['configuration'],
        :ensure         => :present
      }
    end
  end

  def self.get_hook(name)
    rest = get_rest_info
    url = "http://#{rest[:ip]}:#{rest[:port]}/api/collections/hooks/#{name}"

    get_object(name, url)
  end

  private
  def create_hook
    resourceHash = {
      :name          => resource[:name],
      :hook_type     => resource['hook_type'],
      :configuration => resource['configuration'] || {},
    }
    post_command('create-hook', resourceHash)
  end

  def update_hook
    if resource[:ignore_changes]
      Puppet.warning("ignore_changes present, skipping resource update due to configuration change")
    else
      # Hook does not provide an update function
      Puppet.warning("Razor REST API does not provide an update function for the hook.")
      Puppet.warning("Will attempt a delete and create.")

      delete_hook
      create_hook
    end
  end

  def delete_hook
    resourceHash = {
      :name => resource[:name],
    }
    post_command('delete-hook', resourceHash)
  end
end
