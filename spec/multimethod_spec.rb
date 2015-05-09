require 'rspec'
require_relative '../src/multimethod'

describe 'Multimethod tests' do
  class A
    partial_def :concat, [String, String] do |s1, s2|
      s1 + s2
    end
    partial_def :concat, [String, Integer] do |s1,n|
      s1 * n
    end
    partial_def :concat, [Array] do |a|
      a.join
    end
    partial_def :concat, [Object, Object] do |o1, o2|
      "Objetos concatenados"
    end
  end
  a=A.new


  class Tanque

    def atacar_con_metralla objetivo
      "Tra tra tra"
    end
    def atacar_con_canion objetivo
      "canionazooo"
    end
    def atacar_con_satelite objetivo
      "satelite"
    end
    def atacar_distinto objetivo
      "distinto"
    end
  end

  class Soldado
    attr_accessor :nombre

    def initialize nombre
      @nombre = nombre
    end
  end

  class Avion
  end

  it 'concat("hello", " world") devuelve "helloworld"' do
    expect(a.concat('hello', ' world')).to eq('hello world')
  end

  it 'concat("hello", 3) devuelve "hellohellohello"' do
    expect(a.concat("hello", 3)).to eq('hellohellohello')
  end

  it 'concat([hello,  world, !]) devuelve hello world!' do
    expect(a.concat(['hello world!'])).to eq('hello world!')
  end

  it 'concat con 3' do
    expect{a.concat('hello', 'world', '!')}.to raise_error(ArgumentError)
  end

  it 'funciona metodo multimethods()' do
    expect(A.multimethods).to eq([:concat])
  end

  it '(Hello, 2)' do
    expect(a.concat("Hello", 2)).to eq('HelloHello')
  end

  it 'ObjetosConcatenados' do
    expect(a.concat(Object.new,3)).to eq("Objetos concatenados")
  end

  it 'multimethod permite soporta self' do
    class Tanque
      partial_def :ataca_a, [Tanque] do |objetivo|
        self.atacar_con_canion(objetivo)
      end
      partial_def :ataca_a, [Soldado] do |objetivo|
        self.atacar_con_metralla(objetivo)
      end
    end
    t = Tanque.new
    expect(t.ataca_a(Soldado.new("Ryan"))).to eq("Tra tra tra")
    expect(t.ataca_a(Tanque.new)).to eq("canionazooo")
  end

  it 'definicion parcial nueva se agrega a anteriores y no las pisa' do
    class Tanque
      partial_def :ataca_a, [Tanque] do |objetivo|
        self.atacar_con_canion(objetivo)
      end
      partial_def :ataca_a, [Soldado] do |objetivo|
        self.atacar_con_metralla(objetivo)
      end
     partial_def :ataca_a, [Avion] do |avion|
       self.atacar_con_satelite(avion)
     end
    end
    expect(Tanque.new.ataca_a(Avion.new)).to eq("satelite")
    expect(Tanque.new.ataca_a(Soldado.new("Ryan"))).to eq("Tra tra tra")
    expect(Tanque.new.ataca_a(Tanque.new)).to eq("canionazooo")
  end #MAL PROGRAMADO

  it 'definicion parcial cambiada pisa la anterior' do
    class Tanque
      partial_def :ataca_a, [Tanque] do |objetivo|
        self.atacar_con_canion(objetivo)
      end
      partial_def :ataca_a, [Soldado] do |objetivo|
        self.atacar_con_metralla(objetivo)
      end
      partial_def :ataca_a, [Avion] do |avion|
        self.atacar_con_satelite(avion)
      end
    end
    class Tanque
      partial_def :ataca_a, [Soldado] do |soldado|
        self.atacar_distinto(soldado)
      end
    end
    expect(Tanque.new.ataca_a(Soldado.new("Ryan"))).to eq("distinto")
  end

  it 'agrega multimethods a un unico objeto' do
    tanque_modificado = Tanque.new
    tanque_modificado.partial_def :bocinar, [Soldado] do |soldado|
      "Honk Honk! #{soldado.nombre}"
    end
    tanque_modificado.partial_def :bocinar, [Tanque] do |tanque|
      "Hooooooonk!"
    end
    expect(tanque_modificado.bocinar(Soldado.new("pepe"))).to eq("Honk Honk! pepe")
    expect(tanque_modificado.bocinar(Tanque.new)).to eq("Hooooooonk!")
    expect{Tanque.new.tocar_bocina(Tanque.new)}.to raise_error(NoMethodError)

  end

end