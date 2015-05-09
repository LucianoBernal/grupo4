class Clases < Array
  def matches *argumentos
    (self.longitud_correcta(argumentos)) && ((self.argumentos_correctos(argumentos)))
  end

  def argumentos_correctos argumentos
    argumentos.map.with_index { |argumento, index| argumento.is_a? self[index]}.all?
  end

  def longitud_correcta(argumentos)
    argumentos.length == self.length
  end

  def distancia(*argumentos)
    argumentos.map.with_index {|argumento, index| argumento.class.ancestors.index(self[index])*(index+1)}.reduce :+
  end
end

class PartialBlock
  attr_accessor :clases, :bloque

  def initialize clases, &bloque
    raise ArgumentError, 'Error en cantidad de argumentos' unless bloque.arity == clases.length
    @clases = Clases.new clases
    @bloque = bloque
  end

  def call *argumentos
    raise ArgumentError, 'Error de Argumentos, no matchean los tipos' unless self.matches *argumentos
    @bloque.call *argumentos
  end

  #en realidad @clases tiene lo que necesita para saber si matchea, pero creo que es req
  #del tp que un partialBlock lo entienda, cualquier cosa traemos la logica aca
  def matches *argumentos
    @clases.matches *argumentos
  end
end
