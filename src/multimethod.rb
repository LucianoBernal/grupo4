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
      define_method(firma) {|*args| pB = buscar_metodo_menor_distancia.call(firma, *args)
      if pB.nil?
        super(*args)
      else
      instance_exec(*args,&pB.bloque)
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




  def allMultimethod sym
    if cortarIteracion sym
     return []
    else
    implementaciones=Array.new(metodos[sym] || [])
    implementaciones.concat((superclass.allMultimethod sym).select{|partialBlock| implementaciones.all?{|pB|pB.clases!=partialBlock.clases}})
    end
  end

  def cortarIteracion sym
     (estaDefinidoNormal? sym) || (!instance_methods.include? sym)
  end

  def estaDefinidoNormal? sym
     ((instance_methods false).include? sym) && (metodos[sym].nil?)
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
=begin
  def base
    self
  end
=end

#  def self.method_missing(sym,*args,&bloque)
#    self
 #   implementaciones=self.singleton_class.allMultimethod(sym)
=begin    if (implementaciones).size.equal?0
      raise NoMethodError
    else
      posible_partial_block=implementaciones.bsearch{|pB| pB.clases === args[0]}
      if posible_partial_block.nil?
        raise ArgumentError
      else
        argumentos=Array new(*args.drop(1))
        self.instance_exec(argumentos,&posible_partial_block.bloque)
      end
    end
=end
#  end
end


