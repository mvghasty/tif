module METHODIZER
  class STD
    @@variables = {}

    def self.cout(text)
      text_str = text.to_s

      begin
        evaluated_text = self.instance_eval("\"#{text_str.gsub('"', '\"')}\"")
        $stdout.puts(evaluated_text)
      rescue NameError => e
        puts "Erro na interpolação em cout '#{text_str}': Variável não encontrada - #{e.message}"
      rescue SyntaxError => e
         puts "Erro na interpolação em cout '#{text_str}': Erro de sintaxe - #{e.message}"
      rescue Exception => e
         puts "Erro ao avaliar a string de interpolação em cout '#{text_str}': #{e.message}"
      end
    end

    def self.for(init, condition, increment, &block)
       unless init.is_a?(Hash) && init.key?(:val)
         raise "Formato de init inválido para o loop for. Esperado {:val => valor_inicial}"
       end
       unless condition.respond_to?(:call) && increment.respond_to?(:call) && block_given?
         raise "Condition e increment no loop for devem ser callables (Proc ou Lambda), e um bloco deve ser fornecido."
       end

       while condition.call
         block.call(init[:val])
         init[:val] = increment.call(init[:val])
       end
    end

    def self.let(declaration)
      if declaration =~ /^(\w+):\s*&(\w+)\s*=\s*(.+)$/
        name, type, value_part_string = $1, $2, $3.strip

        final_value = nil

        case type
        when "str"
          if value_part_string =~ /^".*"$/
             begin
               final_value = self.instance_eval(value_part_string)
             rescue Exception => e
               raise "Erro ao avaliar o valor string '#{value_part_string}' para '#{name}': #{e.message}"
             end
          else
             final_value = value_part_string
          end
        when "int", "float", "bool"
          begin
            evaluated_value = self.instance_eval(value_part_string)

            final_value = case type
            when "int"    then evaluated_value.to_i
            when "float"  then evaluated_f = evaluated_value.to_f; evaluated_f == evaluated_f.to_i ? evaluated_f : evaluated_f
            when "bool"   then [true, "true", 1].include?(evaluated_value.to_s.downcase)
            end
          rescue NameError => e
            raise "Variável não encontrada ou expressão inválida '#{value_part_string}' na declaração let para '#{name}': #{e.message}"
          rescue SyntaxError => e
             raise "Erro de sintaxe na expressão de valor '#{value_part_string}': #{e.message}"
          rescue Exception => e
             raise "Erro ao avaliar a expressão de valor '#{value_part_string}' para '#{name}': #{e.message}"
          end
        else
          begin
            final_value = self.instance_eval(value_part_string)
          rescue Exception => e
             raise "Erro ao avaliar a expressão de valor '#{value_part_string}' para '#{name}': #{e.message}"
          end
        end

        @@variables[name.to_sym] = final_value

        METHODIZER::STD.define_singleton_method(name.to_sym) { @@variables[name.to_sym] }


        final_value 
      else
        raise "Formato de declaração let inválido: #{declaration}"
      end
    end

    def self.get(name_sym)
      @@variables[name_sym]
    end
  end
end
