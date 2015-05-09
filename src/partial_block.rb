class PartialBlock
  attr_accessor :clases, :bloque

  def initialize clases, &bloque
    raise ArgumentError, 'Error en cantidad de argumentos' unless bloque.arity == clases.length
    @clases = clases
    @bloque = bloque


  end

  def matches *argumentos
     (self.longitudCorrecta(argumentos)) && ((self.argumentosCorrectos(argumentos)))
  end

  def argumentosCorrectos argumentos

    argumentos.map.with_index { |argumento, index| argumento.is_a? @clases[index]}.all?
    #argumentos.all? { |argumento| argumento.is_a? @clases[argumentos.index(argumento)] }
    #de esta forma (la comentada)un partialBlock con [String, Integer] matchea con ("hola", "hola")
    #porque al evaluar el segundo argumento la expresion -argumentos.index(argumento)-
    #retorno 0, y clases[0] es String.
  end

  def longitudCorrecta(argumentos)
    argumentos.length == @clases.length
  end

  def call(*argumentos)
    raise ArgumentError, 'Error de Argumentos, no matchean los tipos' unless self.matches(*argumentos)
    @bloque.call(*argumentos)
  end

  def distancia(*args)
    #retorno = 0
    #args.each_with_index {|elem, index| retorno += elem.class.ancestors.index(@clases[index])*(index+1)}
    #retorno
    #Sori pero si no es en una linea yo no lo hago (?)
    (args.map.with_index {|argumento, index| argumento.class.ancestors.index(@clases[index])*(index+1)}).reduce :+
  end
end