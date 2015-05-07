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
  a = A.new

  it 'concat("hello", " world") devuelve "helloworld"' do
    expect(a.concat('hello', ' world')).to eq('hello world')
  end

  it 'concat("hello", 3) devuelve "hellohellohello"' do
    expect(a.concat("hello", 3)).to eq('hellohellohello')
  end

  it "concat([hello,  world, !]) devuelve hello world!" do
    expect(a.concat(['hello', ' world', '!'])).to eq('hello world!')
  end #ROJO

  it 'concat con 3' do
    expect{a.concat('hello', 'world', '!')}.to raise_error(ArgumentError)
  end #ROJO

  it 'funciona metodo multimethods()' do
    expect(A.multimethods).to eq([:concat])
  end

  it '(Hello, 2)' do
    expect(a.concat("Hello", 2)).to eq('HelloHello')
  end

  it 'ObjetosConcatenados' do
    expect(a.concat(Object.new,3)).to eq("Objetos concatenados")
  end

  it 'agrega multimethods a un unico objeto' do
    class Tanque
    end
    class Soldado
      attr_accessor :nombre

      def initialize nombre
        @nombre = nombre
      end
    end
    class Tanque
    end
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