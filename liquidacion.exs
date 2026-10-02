# Integrantes:
# - Alejandro García Cadavid
# - Daniela Naranjo Sánchez
# - Luisa Fda Salazar González

defmodule Liquidacion do
  @moduledoc """
  Reglas de negocio de pago. Todas las funciones son PURAS.

  Supuesto de redondeo: el valor de cada servicio se redondea al peso entero
  más cercano (`round/1`), de modo que todo el dinero del programa son enteros.
  """

  @tarifa_base 2_500
  @km_bonificacion 80
  @bonificacion_diaria 15_000
  @alquiler_diario 10_000

  @doc """
  Valor de un servicio válido: `km × tarifa base`, ajustado por puntualidad.
  Se calcula con porcentajes enteros (108, 100, 90, 75) para no acumular
  errores de punto flotante.
  """
  def valor_servicio(%{kilometros: km, retraso: retraso}) do
    round(km * @tarifa_base * porcentaje_ajuste(retraso) / 100)
  end

  @doc """
  Porcentaje del valor base que se paga según el retraso (en minutos):
  hasta 0 -> 108 (bonificación 8 %), 1..10 -> 100, 11..30 -> 90, más de 30 -> 75.
  """
  def porcentaje_ajuste(retraso) do
    cond do
      retraso <= 0 -> 108
      retraso <= 10 -> 100
      retraso <= 30 -> 90
      true -> 75
    end
  end

  @doc "Bonificación de un día según los kilómetros acumulados ese día."
  def bonificacion(km_del_dia) when km_del_dia >= @km_bonificacion, do: @bonificacion_diaria
  def bonificacion(_km_del_dia), do: 0

  @doc "Alquiler de la semana: solo si usa bicicleta, por cada día trabajado."
  def alquiler(%{bicicleta: true}, detalle), do: length(detalle) * @alquiler_diario
  def alquiler(_repartidor, _detalle), do: 0

  @doc "Servicios (de una lista) que pertenecen al repartidor con ese código."
  def servicios_de(codigo, servicios), do: Enum.filter(servicios, fn s -> s.repartidor == codigo end)

  @doc """
  Detalle por día de UN repartidor. Recibe solo los servicios válidos de ese
  repartidor y devuelve una lista de mapas, uno por día trabajado (días con al
  menos un servicio válido), ordenada por día.
  """
  def detalle_por_dia(servicios_del_repartidor) do
    servicios_del_repartidor
    |> Enum.group_by(fn s -> s.dia end)
    |> Enum.map(fn {dia, servicios} ->
      km = servicios |> Enum.map(fn s -> s.kilometros end) |> Enum.sum()

      %{
        dia: dia,
        kilometros: km,
        valor_servicios: servicios |> Enum.map(&valor_servicio/1) |> Enum.sum(),
        bonificacion: bonificacion(km)
      }
    end)
    |> Enum.sort_by(fn d -> d.dia end)
  end

  @doc """
  Liquidación de un repartidor a partir de sus servicios válidos.
  Si no tiene servicios, todos los valores son cero.
  """
  def liquidar(repartidor, servicios_del_repartidor) do
    detalle = detalle_por_dia(servicios_del_repartidor)
    valor_servicios = detalle |> Enum.map(fn d -> d.valor_servicios end) |> Enum.sum()
    bonificaciones = detalle |> Enum.map(fn d -> d.bonificacion end) |> Enum.sum()
    alquiler = alquiler(repartidor, detalle)

    %{
      codigo: repartidor.codigo,
      nombre: repartidor.nombre,
      kilometros: detalle |> Enum.map(fn d -> d.kilometros end) |> Enum.sum(),
      valor_servicios: valor_servicios,
      bonificaciones: bonificaciones,
      alquiler: alquiler,
      neto: valor_servicios + bonificaciones - alquiler
    }
  end

  @doc "Liquidación de TODOS los repartidores (incluso los que no tienen servicios)."
  def liquidar_todos(repartidores, servicios_validos) do
    por_repartidor = Enum.group_by(servicios_validos, fn s -> s.repartidor end)

    Enum.map(repartidores, fn r ->
      liquidar(r, Map.get(por_repartidor, r.codigo, []))
    end)
  end
end
