class Commander::Command
  def action(*args, &block)

    wrapper = lambda do |a, options|
      if options.config
        read = Pathname(options.config).read
        json = JSON.parse(read)

        Datapimp.config.apply_all(json)
      end

      Datapimp.config.apply_all(options.to_hash)

      block.call(a, options)
    end

    send(:when_called, *args, &wrapper)
  end

  class Options
    def to_hash
      __hash__
    end
  end
end
