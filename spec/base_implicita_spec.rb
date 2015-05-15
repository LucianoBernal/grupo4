require 'rspec'
require_relative '../src/base'

describe 'Base implicita tests' do
  class PadreImplicit
    partial_def :m, [Object] do |o|
      "A>m"
    end
  end

  class HijoImplicit < PadreImplicit

    partial_def :m, [Integer] do |i|
      base(i) + " => B>m_integer(#{i})"
    end

    partial_def :m, [Numeric] do |n|
      base(n) + " => B>m_numeric"
    end

  end

  it 'funciona base implicita para el ejemplo dado' do
    expect(HijoImplicit.new.m(1)).to eq("A>m => B>m_numeric => B>m_integer(1)")
  end

end