# Integrantes:
# - Alejandro García Cadavid
# - Daniela Naranjo Sánchez
# - Luisa Fda Salazar González

# Carga de módulos (dependencias primero). Se ejecuta con: elixir main.exs
Code.require_file("datos.exs", __DIR__)
Code.require_file("formato.exs", __DIR__)
Code.require_file("validacion.exs", __DIR__)
Code.require_file("liquidacion.exs", __DIR__)
Code.require_file("reportes.exs", __DIR__)
Code.require_file("entrada.exs", __DIR__)
Code.require_file("investigacion.exs", __DIR__)

defmodule Main do
  @moduledoc """
  Punto de entrada. Solo orquesta (IMPURO): carga datos, valida, pide el
  servicio adicional, imprime reportes y pide el comprobante.
  """

  def main do
    repartidores = Datos.repartidores()
    zonas = Datos.zonas()
    servicios = Datos.servicios()

    # Mapas indexados para búsquedas por clave
    mapa_repartidores = Map.new(repartidores, fn r -> {r.codigo, r} end)
    mapa_zonas = Map.new(zonas, fn z -> {z.id, z} end)

    {validos, rechazados} = Validacion.clasificar(servicios, mapa_repartidores, mapa_zonas)

    {validos, rechazados} =
      Entrada.solicitar_servicio_adicional(validos, rechazados, mapa_repartidores, mapa_zonas)

    liquidaciones = Liquidacion.liquidar_todos(repartidores, validos)

    Reportes.r1(rechazados)
    Reportes.r2(validos, zonas)
    km_por_dia = Reportes.r3(validos)
    Reportes.r4(liquidaciones)
    Reportes.r5(validos, mapa_repartidores)
    Reportes.r6(validos, mapa_repartidores)
    Reportes.r7(liquidaciones)
    Reportes.r8(validos, repartidores, zonas)

    Entrada.solicitar_comprobante(validos, mapa_repartidores)

    Investigacion.mostrar_ranking(liquidaciones)
    Investigacion.mostrar_combinacion(km_por_dia)
    Investigacion.mediciones(servicios, repartidores, zonas)
  end
end

Main.main()
