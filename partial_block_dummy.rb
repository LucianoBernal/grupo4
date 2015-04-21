class Partial_block_dummy
  attr_accessor :clases, :bloque

  def initialize clases, &bloque
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
end