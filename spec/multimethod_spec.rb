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
  end
  a = A.new

  it 'concat("hello", " world") devuelve "helloworld"' do
    expect(a.concat('hello', ' world')).to eq('hello world')
  end

  it 'concat("hello", 3) devuelve "hellohellohello"' do
    expect(a.concat("hello", 3)).to eq('hellohellohello')
  end

  it "concat(['hello', ' world', '!']) devuelve 'hello world!'" do
    expect(a.concat(['hello', ' world', '!'])).to eq('hello world!')
  end #DA ROJO

  it 'concat con 3 parametros lanza una excepción!' do
    expect(a.concat('hello', 'world', '!')).to raise_error(ArgumentError)
  end #EMPTY TEST SUITE?

  it 'funciona metodo multimethods()' do
    expect(A.multimethods).to eq([:concat])
  end

  #it 'funciona metodo multimethod(:metodo)' do
  #  expect(A.multimethod(:concat)).to eq(#PONGO LA REPRESENTACION QUE ME TIRA PRY??))
  #end

end