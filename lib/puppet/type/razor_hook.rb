# Custom Type: Razor - Hook

Puppet::Type.newtype(:razor_hook) do
  @doc = "Razor Hook"

  ensurable

  newparam(:name, :namevar => true) do
    desc "The hook name"
  end

  newproperty(:hook_type) do
    desc "The hook type"
  end

  newproperty(:configuration) do
    desc "The hook configuration (Hash)"
    defaultto {}

    def retrieve
      # Trick hook configuration making it think that the current value is the should value when 
      # ignore_changes is true. Inspired by exec's resource returns property
      if self.resource[:ignore_changes]
        return self.should[:configuration]
      else
        provider.class.get_hook(self.resource[:name])[:configuration]
      end
    end
  end

  newparam(:ignore_changes, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc "Update hook if configuration changes are found (Boolean)"
    defaultto false
  end
end
