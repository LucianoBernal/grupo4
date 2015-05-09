require 'rspec'
require_relative '../src/multimethod'

describe 'respond_to? tests' do
  class B
    partial_def :concat, [String, Integer] do |s1,n|
      s1 * n
    end
    partial_def :concat, [Object, Object] do |o1, o2|
      "Objetos concatenados"
    end
  end

  it 'respond_to? 1' do
    expect(B.new.respond_to?(:concat)).to eq(TRUE)
  end

  it 'respond_to? 2' do
    expect(B.new.respond_to?(:to_s)).to eq(TRUE)
  end

  it 'respond_to? 3' do
    expect(B.new.respond_to?(:concat,false,[String,String])).to eq(TRUE)
  end

  it 'respond_to? 4' do
    expect(B.new.respond_to?(:concat,false,[Integer,B])).to eq(TRUE)
  end

  it 'respond_to? 5' do
    expect(B.new.respond_to?(:to_s,false, [String])).to eq(FALSE)
  end #ROJO

  it 'respond_to? 6' do
    expect(B.new.respond_to?(:concat,false, [String,String,String])).to eq(FALSE)
  end #ROJO
end