<% module_namespacing do -%>
class <%= class_name %>< <%= parent_class_name %>
  required do
    model :user
  end

  def execute

  end
end
<% end -%>
