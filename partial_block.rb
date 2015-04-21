require 'pry'


class PartialBlock
  attr_accessor :verdad, :clases
  def initialize clases
    @clases = clases

  end
  def bien clase, elemento
    @verdad = @verdad && (elemento.is_a? clase)

  end
  def matches arg1, *cola
    #FUNCIONA SI O SOLO SI SE LE PASA UN ARGUMENTO COMO MINIMO
    cola.insert(0,arg1)
    @verdad = cola.length == @clases.length
    @clases.each_with_index { |clase, index| self.bien(clase, cola(index)) }
    @verdad
  end
end

binding.pry