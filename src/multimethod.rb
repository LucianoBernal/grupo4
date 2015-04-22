class MultiMethods
  attr_accessor :metodos

  def initialize
    @metodos=Hash.new
  end


  def
  partial_def firma, clases,&bloque
    partialBlock = Partial_block_dummy.new(clases,&bloque)
    if !@metodos.include? firma
      @metodos.store(firma,[partialBlock])
    else
      self.borrarSiEsNecesario(firma,clases)
      @metodos[firma].push(partialBlock)
    end

  end


  def borrarSiEsNecesario(firma,clases)
    @metodos.store(firma,(@metodos[firma].select{|pB|pB.clases!=clases}))
  end

end