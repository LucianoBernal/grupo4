class PartialBlock
  attr_accessor :clases, :bloque

  def initialize clases, &bloque
    raise ArgumentError, 'Error en cantidad de argumentos' unless bloque.arity == clases.length
    @clases = clases
    @bloque = bloque


  end

  def matches *argumentos
    argumentos= argumentos.flatten
    (self.longitudCorrecta(argumentos)) && ((self.argumentosCorrectos(argumentos)))
  end

  def argumentosCorrectos argumentos
    argumentos.all? { |argumento| argumento.is_a? @clases[argumentos.index(argumento)] }
  end

  def longitudCorrecta(argumentos)
    argumentos.length == @clases.length
  end

  def call(*argumentos)
    raise ArgumentError, 'Error de Argumentos, no matchean los tipos' unless self.matches(argumentos)
    @bloque.call(argumentos)
  end

  def distancia(*args)
    retorno = 0
    args.each_with_index {|elem, index| retorno += elem.class.ancestors.index(@clases[index])*(index+1)}
    retorno
  end
end