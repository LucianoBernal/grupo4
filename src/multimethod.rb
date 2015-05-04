require_relative 'partial_block'

class Module
  attr_accessor :metodos

  def metodos
    @metodos = @metodos || Hash.new()
  end


  def
  partial_def firma, clases,&bloque
    partial_block = PartialBlock.new(clases,&bloque)
    if !metodos.include? firma
      define_method(firma) {|*args| instance_exec(firma, *args) {|firma, *argt| pB = buscar_metodo_menor_distancia(firma, *argt)
                                                                                         if pB.nil?
                                                                                                return
                                                                                         end
                                                                                             pB.call(*argt)}}
      metodos.store(firma, [partial_block])
    else
      self.borrarSiEsNecesario(firma,clases)
      metodos[firma].push(partial_block)
    end
  end

  def borrarSiEsNecesario(firma,clases)
    @metodos.store(firma,(@metodos[firma].select{|pB|pB.clases!=clases}))
  end
end

class Object
  def buscar_metodo_menor_distancia firma, *args
    #@metodos[firma].min {|pB| } Seria algo asi..
    #Esto no esta terminado, por lo pronto devuelve el ultimo pb agregado
    self.class.metodos[firma].select{|pB| pB.matches(*args)}.min {|left, right| left.distancia(*args) <=> right.distancia(*args)}
    #Si el resultado de min puede ser en algunos casos un array deberiamos agarrar el primero
    #self.class.metodos[firma][self.class.metodos[firma].size - 1]
  end
end