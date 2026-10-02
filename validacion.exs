# Integrantes:
# - Alejandro García Cadavid
# - Daniela Naranjo Sánchez
# - Luisa Fda Salazar González

defmodule Validacion do
  @moduledoc """
  Validación de servicios. Todas las funciones son PURAS.

  Reglas, en este orden exacto (solo se reporta el primer incumplimiento):
    1. El repartidor existe        -> :repartidor_desconocido
    2. La zona existe              -> :zona_desconocida
    3. Día entero entre 1 y 6      -> :dia_invalido
    4. Km número en (0, 45]        -> :kilometros_fuera_de_rango
    5. Retraso número en [-30,180] -> :retraso_invalido
  """

  @dia_minimo 1
  @dia_maximo 6
  @km_maximo 45
  @retraso_minimo -30
  @retraso_maximo 180

  @motivos [
    :repartidor_desconocido,
    :zona_desconocida,
    :dia_invalido,
    :kilometros_fuera_de_rango,
    :retraso_invalido
  ]

  @doc "Días de operación como lista: [1, 2, 3, 4, 5, 6]."
  def dias, do: Enum.to_list(@dia_minimo..@dia_maximo)

  @doc "Motivos de rechazo, en el orden de validación."
  def motivos, do: @motivos

  @doc """
  Valida un servicio. `repartidores` es un mapa `codigo => repartidor` y
  `zonas` un mapa `id => zona`.

  Devuelve `{:ok, servicio}` o `{:error, motivo}`. Las verificaciones se
  encadenan con `with`, que se detiene en el primer `{:error, _}`.
  """
  def validar(servicio, repartidores, zonas) do
    with {:ok, _} <- validar_repartidor(servicio, repartidores),
         {:ok, _} <- validar_zona(servicio, zonas),
         {:ok, _} <- validar_dia(servicio),
         {:ok, _} <- validar_kilometros(servicio),
         {:ok, _} <- validar_retraso(servicio) do
      {:ok, servicio}
    end
  end

  @doc """
  Valida toda una lista de servicios.

  Devuelve `{validos, rechazados}`: `validos` es la lista de servicios que
  pasaron y `rechazados` una lista de tuplas `{servicio, motivo}`.
  """
  def clasificar(servicios, repartidores, zonas) do
    resultados = Enum.map(servicios, fn s -> {s, validar(s, repartidores, zonas)} end)

    validos = for {_s, {:ok, valido}} <- resultados, do: valido
    rechazados = for {s, {:error, motivo}} <- resultados, do: {s, motivo}

    {validos, rechazados}
  end

  # --- Verificaciones individuales (cada una devuelve {:ok, s} o {:error, motivo}) ---

  defp validar_repartidor(servicio, repartidores) do
    if Map.has_key?(repartidores, Map.get(servicio, :repartidor)) do
      {:ok, servicio}
    else
      {:error, :repartidor_desconocido}
    end
  end

  defp validar_zona(servicio, zonas) do
    if Map.has_key?(zonas, Map.get(servicio, :zona)) do
      {:ok, servicio}
    else
      {:error, :zona_desconocida}
    end
  end

  defp validar_dia(servicio) do
    case Map.get(servicio, :dia) do
      dia when is_integer(dia) and dia >= @dia_minimo and dia <= @dia_maximo ->
        {:ok, servicio}

      _ ->
        {:error, :dia_invalido}
    end
  end

  defp validar_kilometros(servicio) do
    case Map.get(servicio, :kilometros) do
      km when is_number(km) and km > 0 and km <= @km_maximo -> {:ok, servicio}
      _ -> {:error, :kilometros_fuera_de_rango}
    end
  end

  defp validar_retraso(servicio) do
    case Map.get(servicio, :retraso) do
      r when is_number(r) and r >= @retraso_minimo and r <= @retraso_maximo -> {:ok, servicio}
      _ -> {:error, :retraso_invalido}
    end
  end
end
