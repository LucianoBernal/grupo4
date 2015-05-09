require 'rspec'
require_relative '../src/multimethod'

describe 'Herencia tests' do
  class Avion
  end
  class Radar
  end
  class Soldado
  end
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
    partial_def :ataca_a,[Soldado] do |soldado| self.atacar_con_metralla soldado end
    partial_def :ataca_a,[Tanque] do |tanque| self.atacar_con_canion soldado tanque end
  end
  class A
    partial_def :m, [String] do |s|
      "A>m #{s}"
    end

    partial_def :m, [Numeric] do |n|
      "A>m" * n
    end

    partial_def :m, [Object] do |o|
      "A>m and Object"
    end
  end
  class B < A
    partial_def :m, [Object] do |o|
      "B>m and Object"
    end
  end

  it 'multimethod se hereda' do
    class Panzer < Tanque
    end
    panzer = Panzer.new
    expect(panzer.ataca_a(Soldado.new)).to eq('Tra tra tra')
  end

  it 'partial def se agrega sin pisar' do
    class Panzer < Tanque
    partial_def :ataca_a, [Radar] do |radar|
      self.atacar_distinto(radar)
      end
    end
    expect(Panzer.new.ataca_a(Radar.new)).to eq('distinto')
  end

  it 'partial def pisa definicion heredada' do
    class Panzer < Tanque
      partial_def :ataca_a, [Soldado] do |soldado|
        self.atacar_con_canion(soldado)
      end
    end
    expect(Panzer.new.ataca_a(Soldado.new)).to eq('canionazooo')
  end

  it'funciona busqueda menor distancia 1' do
    b = B.new
    expect(b.m("hello")).to eq("A>m hello")
  end

  it'funciona busqueda menor distancia 2' do
    b = B.new
    expect(b.m(Object.new)).to eq("B>m and Object")
  end

end