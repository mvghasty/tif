require_relative 'methodizer'

class TSI
  def main(&block)
    std = METHODIZER::STD
    std.instance_eval(&block)
  end

  def preprocess_tff(code)
    code.gsub(/^(\s*)let\s+([^"\n]+?)$/, '\1let "\2"')
  end

  def load_and_execute(filename)
    code = File.read(filename)
    code = preprocess_tff(code)
    instance_eval(code)
  end
end

if ARGV[0]
  interpreter = TSI.new
  interpreter.load_and_execute(ARGV[0])
else
  puts "Por favor, forneça o caminho do arquivo .tff como argumento." 
end 
