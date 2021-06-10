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

    def retrieve
      # This retrieve logic is taken from exec's resource returns property,
      # hopefully it'll treat the resource as in_sync when ignore_changes is true and
      # so not trigger any change
      if self.resource[:ignore_changes]
        should
      end
      :notrun
    end
  end

  newparam(:ignore_changes, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc "Update hook if configuration changes are found (Boolean)"
    defaultto false
  end
end
