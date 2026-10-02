# Integrantes:
# - Alejandro García Cadavid
# - Daniela Naranjo Sánchez
# - Luisa Fda Salazar González

defmodule Investigacion do
  @moduledoc """
  Parte C: `ranking/2` con keyword lists, `Map.merge/3` y mediciones con
  `:timer.tc/1`.
  """

  @opciones_por_defecto [campo: :kilometros, orden: :desc, limite: 5]

  # ------------------------------------------------- C1. ranking/2 (puro)

  @doc """
  Ranking de una lista de mapas, configurado con una keyword list.

  Opciones (con su valor por defecto):
    - `:campo`  campo por el que se ordena (`:kilometros`)
    - `:orden`  `:asc` o `:desc` (`:desc`)
    - `:limite` cantidad máxima de elementos (`5`)

  Devuelve `{:ok, lista}` o `{:error, motivo}`.

  ## Ejemplos

      Investigacion.ranking(liquidaciones, campo: :neto, limite: 3)
      Investigacion.ranking(liquidaciones, orden: :asc)
  """
  def ranking(coleccion, opciones \\ []) do
    with {:ok, config} <- Keyword.validate(opciones, @opciones_por_defecto),
         campo = Keyword.get(config, :campo),
         orden = Keyword.get(config, :orden),
         limite = Keyword.get(config, :limite),
         :ok <- validar_campo(coleccion, campo),
         :ok <- validar_orden(orden),
         :ok <- validar_limite(limite) do
      ordenada = Enum.sort_by(coleccion, fn elemento -> Map.get(elemento, campo) end, orden)
      {:ok, Enum.take(ordenada, limite)}
    else
      {:error, claves} when is_list(claves) -> {:error, {:opciones_desconocidas, claves}}
      {:error, motivo} -> {:error, motivo}
    end
  end

  defp validar_campo(coleccion, campo) do
    if Enum.all?(coleccion, fn e -> Map.has_key?(e, campo) end),
      do: :ok,
      else: {:error, :campo_inexistente}
  end

  defp validar_orden(orden) when orden in [:asc, :desc], do: :ok
  defp validar_orden(_orden), do: {:error, :orden_invalido}

  defp validar_limite(limite) when is_integer(limite) and limite >= 0, do: :ok
  defp validar_limite(_limite), do: {:error, :limite_invalido}

  # ------------------------------------------------- C2. Map.merge/3 (puro)

  @doc """
  Combina los km por día propios con los de la empresa aliada. Si el día está
  en ambos mapas, se SUMAN los kilómetros (función de conflicto de `Map.merge/3`).
  Un día que solo está en un mapa (como el 7) se copia sin llamar a la función.
  """
  def combinar_km_diarios(km_propios, km_aliada) do
    Map.merge(km_propios, km_aliada, fn _dia, propio, aliado -> propio + aliado end)
  end

  @doc "Lo que haría `Map.merge/2`: en los días repetidos gana el valor del segundo mapa."
  def combinar_sin_sumar(km_propios, km_aliada), do: Map.merge(km_propios, km_aliada)

  # ------------------------------------------------ Presentación (impura)

  @doc "Muestra ejemplos de `ranking/2` sobre las liquidaciones."
  def mostrar_ranking(liquidaciones) do
    IO.puts("\n=== Investigación C1: ranking/2 con keyword lists ===")

    mostrar_caso("ranking(liq, campo: :neto, limite: 3)", ranking(liquidaciones, campo: :neto, limite: 3), :neto)

    mostrar_caso(
      "ranking(liq, campo: :kilometros, orden: :asc, limite: 2)",
      ranking(liquidaciones, campo: :kilometros, orden: :asc, limite: 2),
      :kilometros
    )

    mostrar_caso("ranking(liq, orden: :arriba)", ranking(liquidaciones, orden: :arriba), :kilometros)
    mostrar_caso("ranking(liq, color: :rojo)", ranking(liquidaciones, color: :rojo), :kilometros)
  end

  defp mostrar_caso(llamada, {:ok, lista}, campo) do
    IO.puts("  #{llamada}")

    lista
    |> Enum.with_index(1)
    |> Enum.each(fn {e, pos} -> IO.puts("    #{pos}. #{e.nombre}: #{inspect(Map.get(e, campo))}") end)
  end

  defp mostrar_caso(llamada, {:error, motivo}, _campo) do
    IO.puts("  #{llamada}\n    -> #{inspect(motivo)}")
  end

  @doc "Muestra la combinación con la empresa aliada."
  def mostrar_combinacion(km_por_dia) do
    empresa_aliada = %{1 => 580.5, 2 => 430, 3 => 510, 5 => 625, 7 => 180}

    IO.puts("\n=== Investigación C2: Map.merge/3 ===")
    IO.puts("  Propios (R3):        #{inspect(km_por_dia)}")
    IO.puts("  Empresa aliada:      #{inspect(empresa_aliada)}")
    IO.puts("  Map.merge/2:         #{inspect(combinar_sin_sumar(km_por_dia, empresa_aliada))}")
    IO.puts("  Map.merge/3 (suma):  #{inspect(combinar_km_diarios(km_por_dia, empresa_aliada))}")
  end

  # ------------------------------------------------- C3. Mediciones (impuras)

  @doc """
  Mediciones con `:timer.tc/1` (devuelve `{microsegundos, resultado}`).
  Compara: una validación sola vs promedio de muchas, y buscar un repartidor
  en una lista (`Enum.any?`) frente a un mapa (`Map.has_key?`).
  """
  def mediciones(servicios, repartidores, zonas) do
    mapa_repartidores = Map.new(repartidores, fn r -> {r.codigo, r} end)
    mapa_zonas = Map.new(zonas, fn z -> {z.id, z} end)
    {validos, _} = Validacion.clasificar(servicios, mapa_repartidores, mapa_zonas)
    ultimo = List.last(repartidores).codigo

    IO.puts("\n=== Investigación C3: mediciones con :timer.tc/1 ===")

    {una, _} = :timer.tc(fn -> Validacion.clasificar(servicios, mapa_repartidores, mapa_zonas) end)
    IO.puts("  1) Validar #{length(servicios)} servicios, una sola vez: #{una} µs")

    veces = 1_000
87
    {muchas, _} =
      :timer.tc(fn ->
        repetir(veces, fn -> Validacion.clasificar(servicios, mapa_repartidores, mapa_zonas) end)
      end)

    IO.puts("  2) Validar #{veces} veces: #{muchas} µs en total, #{Formato.decimal(muchas / veces, 2)} µs por vez")

    {liq, _} =
      :timer.tc(fn -> repetir(veces, fn -> Liquidacion.liquidar_todos(repartidores, validos) end) end)

    IO.puts("  3) Liquidar a todos #{veces} veces: #{liq} µs en total, #{Formato.decimal(liq / veces, 2)} µs por vez")

    busquedas = 100_000

    {en_lista, _} =
      :timer.tc(fn ->
        repetir(busquedas, fn -> Enum.any?(repartidores, fn r -> r.codigo == ultimo end) end)
      end)

    {en_mapa, _} =
      :timer.tc(fn -> repetir(busquedas, fn -> Map.has_key?(mapa_repartidores, ultimo) end) end)

    IO.puts("  4) #{busquedas} búsquedas de #{ultimo} en lista (Enum.any?): #{en_lista} µs")
    IO.puts("  5) #{busquedas} búsquedas de #{ultimo} en mapa (Map.has_key?): #{en_mapa} µs")
  end

  # Ejecuta `funcion` `veces` veces (recorrido con Enum, sin recursividad).
  defp repetir(veces, funcion), do: Enum.each(1..veces, fn _ -> funcion.() end)
end
