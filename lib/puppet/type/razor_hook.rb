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
  end

  newparam(:ignore_changes, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc "Update hook if configuration changes are found (Boolean)"
    defaultto false
  end
end
