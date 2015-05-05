require 'rspec'
require_relative '../src/partial_block'

describe 'metaprogramming tests' do
  helloBlock = PartialBlock.new([String]) do |who| "Hello #{who}" end

  it 'New partialBlock with wrong classes arity rise ArgumentError' do
    expect{PartialBlock.new([Object,Object]) do |arg| 1 end}.to raise_error(ArgumentError)
  end

  it 'New partialBlock with wrong block arity rise ArgumentError' do
    expect{PartialBlock.new([Object]) do |arg1,arg2| 1 end}.to raise_error(ArgumentError)
  end

  it 'TP example 1 (matches works: return TRUE with "a")' do
    expect(helloBlock.matches("a")).to eq(TRUE)
  end

  it 'TP example 1 (matches works: return FALSE with 1)' do
    expect(helloBlock.matches(1)).to eq(FALSE)
  end

  it 'TP example 1 (matches works: return FALSE with "a", "b")' do
    expect(helloBlock.matches("a", "b")).to eq(FALSE)
  end

  it 'TP example 1 (call works: returns Hello World! with World!)' do
    expect(helloBlock.call("world!")).to eq("Hello world!")
  end

  it 'TP example 2 (call works: 1 returns ArgumentError: No matchean los tipos)' do
    expect{helloBlock.call(1)}.to raise_error(ArgumentError)
  end

  it 'TP example 3 (block defined with subtypes instances works)' do
    pairBlock = PartialBlock.new([Object, Object]) do |left, right| [left, right] end
    expect(pairBlock.call("hello", 1)).to eq(["hello",1])
  end

  it 'TP example 4 (partial block without arguments works)' do
    pi = PartialBlock.new([]) do 3.14159265359 end
    expect(pi.call()).to eq(3.14159265359)
    expect(pi.matches()).to eq(TRUE)
  end

end