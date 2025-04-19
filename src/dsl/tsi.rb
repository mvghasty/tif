require_relative 'methodizer'

class TSI
  module Fn
    def self.main(&block)
      std = METHODIZER::STD
      std.instance_eval(&block)
    end
  end

  def preprocess(code)
    processed_lines = code.lines.map do |line|
      stripped_line = line.strip
      next '' if stripped_line.empty? || stripped_line.start_with?('#')

      if stripped_line.start_with?('let ')
        declaration_part = stripped_line.sub(/^let\s+/, '').strip
        escaped_declaration_part = declaration_part.gsub('"', '\"')
        "let \"#{escaped_declaration_part}\""
      else
        line
      end
    end
    processed_lines.reject(&:empty?).join("\n")
  end

  def load_and_execute(filename)
    code = File.read(filename)
    processed_code = preprocess(code)
    instance_eval(processed_code)

    rescue NameError => e
      puts "Erro de execução da DSL (Variável/Método): Variável ou método '#{e.name}' não encontrado para #{e.receiver}"
    rescue ArgumentError => e
      puts "--- ArgumentError Capturado ---"
      puts "Erro de execução da DSL (Argumentos): #{e.message}"
      puts "Localização do erro (Stack Trace):"
      puts e.backtrace.join("\n")
      puts "-------------------------------"
    rescue Exception => e
      puts "--- Exception Capturada ---"
      puts "Um erro inesperado ocorreu durante o processamento ou execução da DSL: #{e.message}"
      puts "Localização do erro (Stack Trace):"
      puts e.backtrace.join("\n")
      puts "---------------------------"
    end
end

if ARGV[0]
  interpreter = TSI.new
  interpreter.load_and_execute(ARGV[0])
else
  puts "Por favor, forneça o caminho do arquivo .tff como argumento."
end
