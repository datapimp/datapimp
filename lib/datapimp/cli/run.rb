command "run" do |c|
  c.syntax = "datapimp run FILE"
  c.description = "runs a script in the context of the datapimp config"

  c.option '--format FORMAT', String, 'which format should we serialize the result? json default'

  c.action do |args, options|
    code = ""

    args.each do |arg|
      code += Pathname(arg).read
    end

    result = begin
      eval(code)
    rescue
      {error: $!}
    end

    if options.format == "json"
      puts JSON.generate(result) if result
    else
      puts result
    end
  end
end
