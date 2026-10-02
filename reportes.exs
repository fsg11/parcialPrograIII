# Integrantes:
# - Alejandro García Cadavid
# - Daniela Naranjo Sánchez
# - Luisa Fda Salazar González

defmodule Reportes do
  @moduledoc """
  Reportes R1 a R8.

  Cada reporte se divide en una parte PURA (calcula y devuelve datos) y una
  función IMPURA `rN` (imprime con `IO.puts`).
  """

  @meta_diaria_km 500
  @min_servicios_puntualidad 3

  # ---------------------------------------------------------------- Auxiliares

  defp titulo(texto), do: IO.puts("\n=== #{texto} ===")

  # Nombre y código de un repartidor a partir de su código.
  defp etiqueta(codigo, repartidores) do
    case Map.fetch(repartidores, codigo) do
      {:ok, r} -> "#{r.nombre} (#{codigo})"
      :error -> codigo
    end
  end

  @doc "Suma los kilómetros de una lista de servicios (0 si está vacía)."
  def sumar_kilometros(servicios) do
    servicios |> Enum.map(fn s -> s.kilometros end) |> Enum.sum()
  end

  # ------------------------------------------------------------------------ R1

  @doc "Cuenta los rechazos por motivo. Devuelve un mapa `motivo => cantidad`."
  def contar_rechazos(rechazados) do
    rechazados |> Enum.map(fn {_servicio, motivo} -> motivo end) |> Enum.frequencies()
  end

  @doc "R1: servicios rechazados con su motivo y cantidad por motivo."
  def r1(rechazados) do
    titulo("R1. Servicios rechazados")

    if rechazados == [] do
      IO.puts("  No hubo servicios rechazados.")
    else
      Enum.each(rechazados, fn {servicio, motivo} ->
        IO.puts("  #{inspect(motivo)} <- #{inspect(servicio)}")
      end)
    end

    conteo = contar_rechazos(rechazados)
    IO.puts("\n  Cantidad de rechazos por motivo:")

    Enum.each(Validacion.motivos(), fn motivo ->
      IO.puts("    #{Formato.alinear_izq(inspect(motivo), 30)}#{Map.get(conteo, motivo, 0)}")
    end)

    IO.puts("    #{Formato.alinear_izq("Total", 30)}#{length(rechazados)}")
  end

  # ------------------------------------------------------------------------ R2

  @doc """
  Kilómetros y densidad (km / área) por zona, de mayor a menor densidad.
  Una zona sin servicios aparece con 0 km.
  """
  def kilometros_por_zona(validos, zonas) do
    por_zona = Enum.group_by(validos, fn s -> s.zona end)

    zonas
    |> Enum.map(fn z ->
      km = por_zona |> Map.get(z.id, []) |> sumar_kilometros()
      %{id: z.id, nombre: z.nombre, area: z.area, kilometros: km, densidad: km / z.area}
    end)
    |> Enum.sort_by(fn z -> {-z.densidad, z.id} end)
  end

  @doc "R2: kilómetros por zona y densidad."
  def r2(validos, zonas) do
    titulo("R2. Kilómetros por zona y densidad de recorrido")

    validos
    |> kilometros_por_zona(zonas)
    |> Enum.each(fn z ->
      IO.puts(
        "  #{z.id} #{Formato.alinear_izq(z.nombre, 10)}" <>
          "#{Formato.alinear_der(Formato.kilometros(z.kilometros), 9)} km" <>
          "   área #{Formato.alinear_der(Formato.decimal(z.area, 2), 6)} km²" <>
          "   densidad #{Formato.alinear_der(Formato.decimal(z.densidad, 2), 7)} km/km²"
      )
    end)
  end

  # ------------------------------------------------------------------------ R3

  @doc "Mapa `dia => km` de la empresa; los 6 días aparecen (0 si no hay servicios)."
  def kilometros_por_dia(validos) do
    por_dia = Enum.group_by(validos, fn s -> s.dia end)

    Map.new(Validacion.dias(), fn dia ->
      {dia, por_dia |> Map.get(dia, []) |> sumar_kilometros()}
    end)
  end

  @doc "Se alcanza la meta diaria cuando los km son mayores o iguales a 500."
  def cumple_meta?(km), do: km >= @meta_diaria_km

  @doc "R3: km por día y meta. Devuelve el mapa `dia => km` (lo usa la investigación)."
  def r3(validos) do
    titulo("R3. Kilómetros por día y meta de #{@meta_diaria_km} km")
    km_por_dia = kilometros_por_dia(validos)

    Enum.each(Validacion.dias(), fn dia ->
      km = Map.fetch!(km_por_dia, dia)
      meta = if cumple_meta?(km), do: "meta alcanzada", else: "meta NO alcanzada"
      IO.puts("  Día #{dia}: #{Formato.alinear_der(Formato.kilometros(km), 7)} km  #{meta}")
    end)

    cumplimientos = km_por_dia |> Map.values() |> Enum.map(&cumple_meta?/1)
    IO.puts("\n  ¿Meta alcanzada todos los días?   #{si_no(Enum.all?(cumplimientos, & &1))}")
    IO.puts("  ¿Meta alcanzada al menos un día?  #{si_no(Enum.any?(cumplimientos, & &1))}")

    km_por_dia
  end

  defp si_no(true), do: "Sí"
  defp si_no(false), do: "No"

  # ------------------------------------------------------------------------ R4

  @doc "Ordena liquidaciones por neto descendente (desempate por código)."
  def ordenar_por_neto(liquidaciones) do
    Enum.sort_by(liquidaciones, fn l -> {-l.neto, l.codigo} end)
  end

  @doc "R4: liquidación de todos los repartidores, numerada y ordenada por neto."
  def r4(liquidaciones) do
    titulo("R4. Liquidación semanal de repartidores")

    IO.puts(
      "  " <>
        Formato.alinear_der("#", 3) <>
        "  " <>
        Formato.alinear_izq("Cód.", 6) <>
        Formato.alinear_izq("Nombre", 18) <>
        Formato.alinear_der("Km", 8) <>
        Formato.alinear_der("Servicios", 14) <>
        Formato.alinear_der("Bonific.", 11) <>
        Formato.alinear_der("Alquiler", 11) <>
        Formato.alinear_der("Neto", 14)
    )

    liquidaciones
    |> ordenar_por_neto()
    |> Enum.with_index(1)
    |> Enum.each(fn {l, posicion} ->
      IO.puts(
        "  " <>
          Formato.alinear_der(posicion, 3) <>
          "  " <>
          Formato.alinear_izq(l.codigo, 6) <>
          Formato.alinear_izq(l.nombre, 18) <>
          Formato.alinear_der(Formato.kilometros(l.kilometros), 8) <>
          Formato.alinear_der(Formato.pesos(l.valor_servicios), 14) <>
          Formato.alinear_der(Formato.pesos(l.bonificaciones), 11) <>
          Formato.alinear_der(Formato.pesos(l.alquiler), 11) <>
          Formato.alinear_der(Formato.pesos(l.neto), 14)
      )
    end)
  end

  # ------------------------------------------------------------------------ R5

  @doc """
  Para cada día, el máximo de km de un repartidor y la lista (ordenada) de
  todos los que lo alcanzaron. Un día sin servicios tiene `lideres: []`.
  """
  def lideres_por_dia(validos) do
    por_dia = Enum.group_by(validos, fn s -> s.dia end)

    Enum.map(Validacion.dias(), fn dia ->
      km_por_repartidor =
        por_dia
        |> Map.get(dia, [])
        |> Enum.group_by(fn s -> s.repartidor end)
        |> Enum.map(fn {codigo, servicios} -> {codigo, sumar_kilometros(servicios)} end)

      case km_por_repartidor do
        [] ->
          %{dia: dia, kilometros: 0, lideres: []}

        _ ->
          maximo = km_por_repartidor |> Enum.map(fn {_c, km} -> km end) |> Enum.max()
          lideres = for {codigo, km} <- km_por_repartidor, km == maximo, do: codigo
          %{dia: dia, kilometros: maximo, lideres: Enum.sort(lideres)}
      end
    end)
  end

  @doc """
  Quién(es) ocupó(ocuparon) el primer lugar en más días. Cada día cuenta para
  todos los empatados de ese día. Devuelve `{dias, codigos}`.
  """
  def primeros_lugares(lideres) do
    conteo =
      lideres
      |> Enum.flat_map(fn d -> d.lideres end)
      |> Enum.frequencies()

    if conteo == %{} do
      {0, []}
    else
      maximo = conteo |> Map.values() |> Enum.max()
      {maximo, for({codigo, n} <- conteo, n == maximo, do: codigo) |> Enum.sort()}
    end
  end

  @doc "R5: repartidor que más km recorrió cada día."
  def r5(validos, repartidores) do
    titulo("R5. Repartidor con más kilómetros cada día")
    lideres = lideres_por_dia(validos)

    Enum.each(lideres, fn
      %{dia: dia, lideres: []} ->
        IO.puts("  Día #{dia}: sin servicios válidos")

      %{dia: dia, kilometros: km, lideres: codigos} ->
        nombres = codigos |> Enum.map(fn c -> etiqueta(c, repartidores) end) |> Enum.join(" y ")
        IO.puts("  Día #{dia}: #{nombres} con #{Formato.kilometros(km)} km")
    end)

    case primeros_lugares(lideres) do
      {0, []} ->
        IO.puts("\n  Nadie ocupó el primer lugar.")

      {dias, codigos} ->
        nombres = codigos |> Enum.map(fn c -> etiqueta(c, repartidores) end) |> Enum.join(" y ")
        IO.puts("\n  Primer lugar en más días (#{dias} días): #{nombres}")
    end
  end

  # ------------------------------------------------------------------------ R6

  @doc """
  Puntualidad de quienes tienen al menos 3 servicios válidos, de mejor a peor.
  Retraso ponderado = suma(retraso × km) / suma(km). Se incluye también el
  promedio simple para comparar. Los km son siempre mayores que 0, por lo que
  no hay división por cero.
  """
  def puntualidad(validos) do
    validos
    |> Enum.group_by(fn s -> s.repartidor end)
    |> Enum.filter(fn {_codigo, servicios} -> length(servicios) >= @min_servicios_puntualidad end)
    |> Enum.map(fn {codigo, servicios} ->
      km = sumar_kilometros(servicios)
      ponderado = (servicios |> Enum.map(fn s -> s.retraso * s.kilometros end) |> Enum.sum()) / km
      simple = (servicios |> Enum.map(fn s -> s.retraso end) |> Enum.sum()) / length(servicios)
      %{codigo: codigo, servicios: length(servicios), ponderado: ponderado, simple: simple}
    end)
    |> Enum.sort_by(fn p -> {p.ponderado, p.codigo} end)
  end

  @doc "R6: mejor puntualidad ponderada (menor retraso ponderado)."
  def r6(validos, repartidores) do
    titulo("R6. Mejor puntualidad (retraso ponderado por km)")

    case puntualidad(validos) do
      [] ->
        IO.puts("  Ningún repartidor tiene al menos #{@min_servicios_puntualidad} servicios válidos.")

      [mejor | _] = candidatos ->
        ganadores = Enum.filter(candidatos, fn p -> p.ponderado == mejor.ponderado end)

        Enum.each(ganadores, fn p ->
          IO.puts(
            "  Mejor: #{etiqueta(p.codigo, repartidores)} con retraso ponderado de " <>
              "#{Formato.decimal(p.ponderado, 2)} min (#{p.servicios} servicios)"
          )
        end)

        IO.puts("\n  Comparación de candidatos (ponderado vs promedio simple, en minutos):")

        Enum.each(candidatos, fn p ->
          IO.puts(
            "    #{Formato.alinear_izq(etiqueta(p.codigo, repartidores), 30)}" <>
              "ponderado #{Formato.alinear_der(Formato.decimal(p.ponderado, 2), 7)}" <>
              "   simple #{Formato.alinear_der(Formato.decimal(p.simple, 2), 7)}"
          )
        end)
    end
  end

  # ------------------------------------------------------------------------ R7

  @doc "Total pagado: suma de los netos de todos los repartidores."
  def total_pagado(liquidaciones), do: liquidaciones |> Enum.map(fn l -> l.neto end) |> Enum.sum()

  @doc "Costo promedio por km; `{:error, :sin_kilometros}` si no hay kilómetros."
  def costo_por_km(_total, km) when km == 0, do: {:error, :sin_kilometros}
  def costo_por_km(total, km), do: {:ok, total / km}

  @doc "R7: total pagado y costo promedio por kilómetro."
  def r7(liquidaciones) do
    titulo("R7. Total pagado y costo por kilómetro")
    total = total_pagado(liquidaciones)
    km = liquidaciones |> Enum.map(fn l -> l.kilometros end) |> Enum.sum()

    IO.puts("  Total pagado en la semana: #{Formato.pesos(total)}")
    IO.puts("  Kilómetros totales:        #{Formato.kilometros(km)} km")

    case costo_por_km(total, km) do
      {:ok, costo} -> IO.puts("  Costo promedio por km:     #{Formato.pesos(round(costo))}")
      {:error, :sin_kilometros} -> IO.puts("  Costo promedio por km:     no calculable (0 km)")
    end
  end

  # ------------------------------------------------------------------------ R8

  @doc "Repartidores con al menos un servicio válido en TODAS las zonas."
  def en_todas_las_zonas(validos, repartidores, zonas) do
    ids = MapSet.new(zonas, fn z -> z.id end)
    por_repartidor = Enum.group_by(validos, fn s -> s.repartidor end)

    Enum.filter(repartidores, fn r ->
      cubiertas = por_repartidor |> Map.get(r.codigo, []) |> MapSet.new(fn s -> s.zona end)
      MapSet.subset?(ids, cubiertas)
    end)
  end

  @doc "R8: repartidores que trabajaron en todas las zonas."
  def r8(validos, repartidores, zonas) do
    titulo("R8. Repartidores con servicios en todas las zonas")

    case en_todas_las_zonas(validos, repartidores, zonas) do
      [] -> IO.puts("  Ningún repartidor trabajó en todas las zonas.")
      lista -> Enum.each(lista, fn r -> IO.puts("  #{r.nombre} (#{r.codigo})") end)
    end
  end
end
