require_relative 'partial_block'

class Module
  attr_accessor :metodos

  alias_method :old_respond, :respond_to?

  def metodos
    @metodos = @metodos || Hash.new()
  end

  def
  partial_def firma, clases, &bloque
    partial_block = PartialBlock.new(clases, &bloque)
    buscar_metodo_menor_distancia= Proc.new { |sym, *argt| self.metodos[sym].select { |pB| pB.matches(*argt) }.min { |left, right| left.distancia(*argt) <=> right.distancia(*argt) } }
    if !metodos.include? firma
      define_method(firma) { |*args| pB = instance_exec(firma, *args) {buscar_metodo_menor_distancia.call(firma, *args)}
      if pB.nil?
        super(*args)
      else
      pB.call(*args)
      end}
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
    metodos.keys.concat(instance_eval {self.ancestors[1].multimethods})
  end

  def multimethod sym
    raise NoMethodError, 'No existe el multimethod' unless metodos[sym] != nil
    metodos[sym]
  end
  def respondo_a? sym, clases
    if metodos[sym].nil?
      return false
    end
    (metodos[sym].any? {|pB| pB.clases === clases})
  end

  def respond_to? sym, priv = false, clases = []
    #if clases.nil?
    if instance_eval {self.equal? Module}
      return false
    end
    self.old_respond(sym, priv) || self.respondo_a?(sym, clases) || self.ancestors[1].respondo_a?(sym, clases)
    #else
    #  clases_obtenidas = metodos[sym] || Array.new
    #  clases_obtenidas.any? { |pB| pB.clases = clases }
    #end

  end
end

class Object
  def
  partial_def firma, clases, &bloque
    self.singleton_class.partial_def firma, clases, &bloque
  end
  def multimethods
    []
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
