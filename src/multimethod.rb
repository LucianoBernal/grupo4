require_relative 'partial_block'

class Module
  attr_accessor :metodos

  alias_method :old_respond, :respond_to?

  def metodos
    @metodos = @metodos || Hash.new()
  end

  def metodos_totales
    ## metodos.merge!(super) {|key, valor_mio, valor_super|
    ##                valor_mio.concat(valor_super.select{|pB| valor_mio.all?{|pB_prioridad| pB_prioridad.clases!=pB.clases} })}
    acum=metodos
    self.ancestors.each { |ancestro| acum= acum.merge!(ancestro.metodos) { |key, valor_mio, valor_super|
      valor_mio.concat(valor_super.select { |pB| valor_mio.all? { |pB_prioridad| pB_prioridad.clases!=pB.clases } }) } }
    acum
  end


  def
  partial_def firma, clases, &bloque
    partial_block = PartialBlock.new(clases, &bloque)
    buscar_metodo_menor_distancia= Proc.new { |sym, *argt| self.metodos_totales[sym].select { |pB| pB.matches(*argt) }.min { |left, right| left.distancia(*argt) <=> right.distancia(*argt) } }
    if !metodos.include? firma
      define_method(firma) { |*args| pB = instance_exec(firma, *args) {buscar_metodo_menor_distancia.call(firma,*args)}
      if pB.nil?
        raise ArgumentError, 'Error de Argumentos'
      end
      pB.call(*args) }
      metodos.store(firma, [partial_block])
    else
      self.borrarSiEsNecesario(firma, clases)
      metodos[firma].push(partial_block)
    end
  end

  def borrarSiEsNecesario(firma, clases)
    @metodos.store(firma, (@metodos[firma].select { |pB| pB.clases!=clases }))
  end

  def multimethods
    metodos_totales.keys
  end

  def multimethod sym
    raise NoMethodError, 'No existe el multimethod' unless metodos_totales[sym] != nil
    metodos_totales[sym]
  end

  def respond_to? sym, priv = false, clases = nil
    if clases.nil?
      self.old_respond(sym, priv) || self.multimethods.include?(sym)
    else
      clases_obtenidas = metodos_totales[sym] || Array.new
      clases_obtenidas.any? { |pB| pB.clases = clases }
    end

  end
end

class Object
  def
  partial_def firma, clases, &bloque
    self.singleton_class.partial_def firma, clases, &bloque
  end

end

class A
  partial_def :concat, [String, String] do |s1, s2|
    s1 + s2
  end

  partial_def :concat, [String, Integer] do |s1, n|
    s1 * n
  end

  partial_def :concat, [Array] do |a|
    a.join
  end

  partial_def :concat, [Object, Object] do |o1, o2|
    "Objetos concatenados"
  end
end
