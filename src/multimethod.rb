require_relative 'partial_block'
require_relative 'base'


class PartialMethod
  attr_accessor :sym, :partial_blocks

  def partial_blocks
    @partial_blocks = @partial_blocks || []
  end

  def initialize sym
    @sym = sym
  end

  def borrarSiEsNecesario(clases)
    self.partial_blocks= Array.new(partial_blocks.select { |pB| pB.clases!=clases })
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
    p_method.borrarSiEsNecesario(partial_block.clases)
    p_method.partial_blocks.unshift partial_block
   end
end


class Module

  def partial_methods
    @partial_methods = @partial_methods || PartialMethodList.new
  end

  def partial_method sym
    partial_methods.partial_method sym
  end


  def partial_def sym, clases, &bloque
    buscar_metodo_menor_distancia= Proc.new { |sym, *argt| self.dame_clase.allMultimethod(sym).select { |pB| pB.matches(*argt) }.min_by{|p_block| p_block.clases.distancia *argt} }
    if partial_method(sym).nil?
      define_method(:base){|*args|
        if(args.eql? [])
          return Base.new(self)
        else
          return BaseImplicita.unique_instance.ejecutate(*args)
        end
      }
      define_method(:partial_def){|firma, clases, &bloque|
        self.singleton_class.partial_def firma, clases, &bloque
      }
      define_method(sym) {|*args| pB = instance_exec(sym,*args,&buscar_metodo_menor_distancia)
      if pB.nil?
        raise ArgumentError,'Error de argumentos'
      else
        BaseImplicita.unique_instance.cambiar_todo_el_contexto(self,sym,pB.clases)
        instance_exec(*args,&pB.bloque)
      end}
    end
    partial_methods.agregar_partial_block sym, PartialBlock.new(clases, &bloque)
  end

  def multimethods
    retorno=Array.new (partial_methods.map{|partial_method| partial_method.sym})
    ancestros=self.dame_clase.ancestors
    ancestros.each{|ancestro|
      ancestro_multimethods=Array.new(ancestro.partial_methods.map{|partial_method| partial_method.sym})
      ancestro_multimethods.each{|sym|
        if (self.respond_to?sym)
          retorno.push(sym)
        end
      }
    }
    retorno.uniq
   end

  def multimethod sym
    raise NoMethodError, 'No existe el multimethod' unless partial_method(sym) != nil
    partial_method(sym).partial_blocks
  end

  def allMultimethod sym
    if cortarIteracion sym
      return []
    else
      p_methods=[]
      if partial_method(sym) != nil
        p_methods=partial_method(sym).partial_blocks
      end
      implementaciones=Array.new(p_methods)
      implementaciones.concat((superclass.allMultimethod sym).select{|partialBlock| implementaciones.all?{|pB|pB.clases!=partialBlock.clases}})
    end
  end

  def cortarIteracion sym
    (estaDefinidoNormal? sym) || (!instance_methods.include? sym)
  end

  def estaDefinidoNormal? sym
    ((instance_methods false).include? sym) && (partial_method(sym).nil?)
  end

  def matcheaAlguno(sym,clases)
    allMultimethod(sym).any?{|pB|pB.matches(*clases)}
  end

  def dame_clase
    self
  end

end



class Object

  def respond_to?(sym,priv=false,clases=nil)
    if(clases.nil?)
      super(sym,priv)
    else
      self.dame_clase.matcheaAlguno sym,clases
    end
  end

  def dame_clase
    self.singleton_class
  end
end