require_relative 'multimethod.rb'

class Base
  attr_accessor :contexto

  def initialize(context)
    @contexto=context
  end


  def ejecutar_con_base(sym,clases,args)
    implementaciones=@contexto.dame_clase.allMultimethod(sym)
    if (implementaciones).size.equal?0
      raise NoMethodError
    else
      posible_partial_block=implementaciones.select{|pB| pB.clases.eql? clases}
      if posible_partial_block.eql? []
        raise ArgumentError
      else
        BaseImplicita.unique_instance.cambiar_todo_el_contexto(@contexto,sym,clases)
        @contexto.instance_exec(*args,&posible_partial_block[0].bloque)
      end
    end
  end

  def method_missing(sym,*args,&bloque)
    clases=args[0]
    argumentosMetodo=Array.new(args.drop(1))
    if (!(clases.eql? []) && (argumentosMetodo.eql? []))
      raise ArgumentError, 'Faltan argumentos'
    end
    ejecutar_con_base(sym,clases,argumentosMetodo)

  end
end


class BaseImplicita < Base
  attr_accessor :clases,:sym
  def initialize
  end
  @@unique_instance=BaseImplicita.new

  def self.unique_instance
    @@unique_instance
  end

  def cambiar_todo_el_contexto(contexto,selector,clases)
    @clases = clases
    @contexto = contexto
    @sym = selector
  end


  def ejecutate(*args)
    multimethods_ordenados=Array.new(contexto.dame_clase.allMultimethod(sym).select { |pB| pB.matches(*args) }.sort_by{|p_block| p_block.clases.distancia *args} )
    index=multimethods_ordenados.index{|pB|pB.clases.eql?(clases)}+1
    pB_a_ejectuar=multimethods_ordenados[index]
    return ejecutar_con_base(sym,pB_a_ejectuar.clases,*args)

  end

end

class ErrorSingletonNoSeInstancia < Exception

end
