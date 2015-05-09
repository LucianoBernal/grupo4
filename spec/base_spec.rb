require 'rspec'
require_relative '../src/base'

describe 'Base tests' do
  class Padre
    partial_def :m, [Object] do |o|
      "A>m"
    end
  end

  class Hijo < Padre
    partial_def :m, [Integer] do |i|
      base.m([Numeric], i) + " => B>m_integer(#{i})"
    end

    partial_def :m, [Numeric] do |n|
      base.m([Object], n) + " => B>m_numeric"
    end

    partial_def :o, [Integer] do |oi|
      "O method => " + base.m([Integer], oi)
    end
  end

  it 'funciona base en el propio metodo (pasando por todas las implementaciones de m)' do
    expect(Hijo.new.m(1)).to eq("A>m => B>m_numeric => B>m_integer(1)")
  end

  it 'funciona base en el otro metodo' do
    expect(Hijo.new.m(1.0)).to eq("A>m => B>m_numeric")
  end

  it 'funciona base llamando a otros metodos' do
    expect(Hijo.new.o(1)).to eq("O method => A>m => B>m_numeric => B>m_integer(1)")
  end

end