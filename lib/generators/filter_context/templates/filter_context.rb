<% module_namespacing do -%>
class <%= class_name %>FilterContext < <%= parent_class_name %>
  def build_scope
    @scope ||= self.scope
  end
end
<% end -%>
