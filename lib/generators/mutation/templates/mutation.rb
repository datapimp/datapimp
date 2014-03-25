<% module_namespacing do -%>
class <%= mutation_class_name %>< <%= parent_class_name %>
  required do
    model :user
    hash :<%= mutation_resource_identifier %>
  end

  def execute

  end
end
<% end -%>
