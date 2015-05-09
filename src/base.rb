require_relative 'multimethod.rb'

class Base
  attr_accessor :contexto

  def initialize(context)
    @contexto=context
  end


  def ejecutar_con_base(sym,clases,args)
    implementaciones=@contexto.singleton_class.allMultimethod(sym)
    if (implementaciones).size.equal?0
      raise NoMethodError
    else
      posible_partial_block=implementaciones.select{|pB| pB.clases === clases}
      if posible_partial_block.eql? []
        raise ArgumentError
      else
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

class Object
  def base
    Base.new(self)
  end
end