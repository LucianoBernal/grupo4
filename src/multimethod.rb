class Multimethod
  attr_accessor :firmas
  def self.init
    @firmas = Array.new()
  end

  def partial_def firma, clases, &bloque
    partialBlock = Partial_block.new(clases,&bloque)
    if (@firmas.select{|firmaElement| firmaElement === firma}.size > 0){

    } else {

    }


  end

  end
end