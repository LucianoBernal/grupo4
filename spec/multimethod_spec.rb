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
    expect(b.concat('hello', ' world')).to eq('hello world')
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

  #it 'funciona metodo multimethod(:metodo)' do
  #  expect(A.multimethod(:concat)).to eq(#PONGO LA REPRESENTACION QUE ME TIRA PRY??))
  #end

  it '(Hello, 2)' do
    expect(a.concat("Hello", 2)).to eq('HelloHello')
  end

  it 'ObjetosConcatenados' do
    expect(a.concat(Object.new,3)).to eq("Objetos concatenados")
  end

end