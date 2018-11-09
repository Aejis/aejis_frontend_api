##
# Find a constant in any of the given classes
#
module NestedConstFinder
  def self.nested_const_get(nesting, const)
    resource_class = nesting.map do |mod|

      mod.const_get(const)
                     rescue NameError, LoadError
                       nil

    end
    resource_class.find { |a| a } or raise NameError, "Constant #{const} not found in any of #{nesting}"
  end
end
