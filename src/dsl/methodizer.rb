module METHODIZER
  class STD
    def self.cout(text)
      $stdout.puts(text)
    end

    def for(init, condition, increment)
      while condition.call
        yield(init[:val])
        init[:val] = increment.call(init[:val])
      end
    end

    @@variables = {}

    def self.let(declaration)
      if declaration =~ /^(\w+):\s*&(\w+)\s*=\s*(.+)$/
        name, type, value = $1, $2, $3

        value = case type
        when "int" then value.to_i
        when "float" then value.to_f
        when "string" then value.to_s
        when "bool" then value == "true"
        else value
        end

        @@variables[name.to_sym] = value
        Object.class_eval { define_method(name) { @@variables[name.to_sym] } }

        value
      else
        raise "Invalid let declaration format: #{declaration}"
      end
    end

    def self.get(name)
      @@variables[name.to_sym]
    end
  end
end

@std = METHODIZER::STD
