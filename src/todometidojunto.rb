#La idea de este file es tirar estas cosas que mas o menos andan
#si les gustan tirenlo a los archivos principales
#Yo no lo tocaria a la ligera ahora que funciona, besitos (?

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

class PartialMethod
  attr_accessor :sym, :partial_blocks

  def partial_blocks
    @partial_blocks = @partial_blocks || []
  end

  def initialize sym
    @sym = sym
  end

  def bloque_por_min_dist *args
    #El [] es para no hacer nil.min{} en caso de que ninguno matchee
    (partial_blocks.select {|p_block| p_block.matches *args} || []).min {|p_block| p_block.clases.distancia *args}
  end

  def self.dummy
    #La idea es obtener un objeto que entienda bloque_por_min_dist pero que de nil de movida
    PartialMethod.new 73
  end
end

class PartialMethodList < Array

  def partial_method sym
    select{|p_method| p_method.sym == sym}.first
  end

  def agregar_partial_block sym, partial_block
    p_method = partial_method sym
    if p_method.nil?
      p_method = PartialMethod.new sym
      unshift p_method
    end
    p_method.partial_blocks.unshift partial_block
    #Si quieren hacer borrarSiEsNecesario deberiamos meterlo en una PartialBlockList
    #A mi espiritualmente me alcanza con unshift
  end
end

class Module

  def partial_methods
    @partial_methods = @partial_methods || PartialMethodList.new
  end

  def partial_method sym
    partial_methods.partial_method sym
    #Dios y Nico me perdonen por esta mierda
  end

  def llamar_metodo_padre sym, *args
    instance_exec(*args){|*t| superclass.method(sym).call(*t)}
    #para mi esto deberia ser equivalente a
  end

  def partial_def sym, clases, &bloque
    #Anda pesimo todavia en asuntos de herencia
    p_method = partial_method sym
    if p_method.nil?
      define_method(sym) {|*args| instance_exec(sym, *args) {|s, *t| p_block = (self.class.partial_method(s)||PartialMethod.dummy).bloque_por_min_dist(*t)
                                                if p_block.nil?
                                                  #super(*args)
                                                  self.class.llamar_metodo_padre(s, *t)
                                                else
                                                  p_block.call(*t)
                                                  end
                                                  }}
    end
    partial_methods.agregar_partial_block sym, PartialBlock.new(clases, &bloque)
  end

end