command "run" do |c|
  c.syntax = "datapimp run FILE"
  c.description = "runs a script in the context of the datapimp config"

  c.action do |args, options|
    args.each do |arg|
      code += Pathname(arg).read
    end

    eval(code)
  end
end
