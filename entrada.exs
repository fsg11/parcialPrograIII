# Integrantes:
# - Alejandro García Cadavid
# - Daniela Naranjo Sánchez
# - Luisa Fda Salazar González

defmodule Entrada do
  @moduledoc """
  Interacción con el usuario: servicio adicional y comprobante.

  Las funciones que leen del teclado o imprimen son IMPURAS. El análisis del
  texto (`parsear_numero/1`, `parsear_servicio/1`, `procesar_entrada/3`) y el
  armado del comprobante son PUROS, así se pueden probar sin teclado.
  """

  # ---------------------------------------------------------------- Lectura

  # IO.gets puede devolver :eof o {:error, _}; ambos se tratan como cadena vacía.
  defp leer_linea(mensaje) do
    case IO.gets(mensaje) do
      texto when is_binary(texto) -> String.trim(texto)
      _ -> ""
    end
  end

  # ------------------------------------------------------- Análisis (puro)

  @doc """
  Convierte texto a número: entero si es posible, si no decimal.
  Exige que todo el texto sea el número (sin restos). `{:ok, n}` o `:error`.
  """
  def parsear_numero(texto) do
    case Integer.parse(texto) do
      {entero, ""} ->
        {:ok, entero}

      _ ->
        case Float.parse(texto) do
          {real, ""} -> {:ok, real}
          _ -> :error
        end
    end
  end

  @doc """
  Convierte `repartidor;zona;dia;kilometros;retraso` en un servicio.
  Devuelve `{:ok, servicio}` o `{:error, :formato_invalido}` si no tiene
  exactamente 5 campos, o si día, kilómetros o retraso no son numéricos
  (el día debe ser entero). Repartidor y zona se dejan tal cual (sin pasar a
  mayúsculas): la validación posterior decide si existen.
  """
  def parsear_servicio(linea) do
    campos = linea |> String.split(";") |> Enum.map(&String.trim/1)

    with [repartidor, zona, dia, km, retraso] <- campos,
         {dia_entero, ""} <- Integer.parse(dia),
         {:ok, km_numero} <- parsear_numero(km),
         {:ok, retraso_numero} <- parsear_numero(retraso) do
      {:ok,
       %{
         repartidor: repartidor,
         zona: zona,
         dia: dia_entero,
         kilometros: km_numero,
         retraso: retraso_numero
       }}
    else
      _ -> {:error, :formato_invalido}
    end
  end

  @doc """
  Procesa el texto ingresado y devuelve uno de:
    - `:omitido`
    - `{:agregado, servicio}`
    - `{:rechazado_formato, :formato_invalido}`
    - `{:rechazado_regla, servicio, motivo}`
  """
  def procesar_entrada("", _repartidores, _zonas), do: :omitido

  def procesar_entrada(texto, repartidores, zonas) do
    case parsear_servicio(texto) do
      {:error, motivo} ->
        {:rechazado_formato, motivo}

      {:ok, servicio} ->
        case Validacion.validar(servicio, repartidores, zonas) do
          {:ok, valido} -> {:agregado, valido}
          {:error, motivo} -> {:rechazado_regla, servicio, motivo}
        end
    end
  end

  # ------------------------------------------------ Servicio adicional

  @doc """
  Solicita UN servicio adicional, informa el resultado y devuelve
  `{validos, rechazados}` actualizados. Un servicio rechazado por regla se
  agrega a `rechazados` (aparece en R1); uno rechazado por formato no, porque
  nunca llegó a ser un servicio.
  """
  def solicitar_servicio_adicional(validos, rechazados, repartidores, zonas) do
    IO.puts("\nIngrese un servicio adicional")
    IO.puts("(repartidor;zona;dia;kilometros;retraso)")
    IO.puts("o Enter para omitir:")

    resultado = procesar_entrada(leer_linea("> "), repartidores, zonas)
    informar(resultado)
    aplicar(resultado, validos, rechazados)
  end

  defp informar(:omitido), do: IO.puts("No se ingresó ningún servicio adicional.")
  defp informar({:agregado, _}), do: IO.puts("Servicio adicional agregado correctamente.")

  defp informar({:rechazado_formato, _}),
    do: IO.puts("Servicio rechazado por formato inválido (:formato_invalido).")

  defp informar({:rechazado_regla, _, motivo}),
    do: IO.puts("Servicio rechazado por regla de validación: #{inspect(motivo)}.")

  defp aplicar({:agregado, servicio}, validos, rechazados), do: {validos ++ [servicio], rechazados}

  defp aplicar({:rechazado_regla, servicio, motivo}, validos, rechazados),
    do: {validos, rechazados ++ [{servicio, motivo}]}

  defp aplicar(_otro, validos, rechazados), do: {validos, rechazados}

  # ------------------------------------------------------- Comprobante

  @doc """
  Arma (PURO) los datos del comprobante de un repartidor: su detalle por día
  (solo días con servicios válidos) y su liquidación.
  """
  def armar_comprobante(repartidor, validos) do
    servicios = Liquidacion.servicios_de(repartidor.codigo, validos)

    %{
      repartidor: repartidor,
      detalle: Liquidacion.detalle_por_dia(servicios),
      liquidacion: Liquidacion.liquidar(repartidor, servicios)
    }
  end

  @doc """
  Solicita el código de un repartidor y muestra su comprobante. Si el código
  no existe, informa y continúa.
  """
  def solicitar_comprobante(validos, repartidores) do
    codigo =
      "\nIngrese el código del repartidor para ver su comprobante: "
      |> leer_linea()

    case Map.fetch(repartidores, codigo) do
      {:ok, repartidor} ->
        repartidor |> armar_comprobante(validos) |> imprimir_comprobante()

      :error ->
        IO.puts("No existe ningún repartidor con el código \"#{codigo}\".")
    end
  end

  defp imprimir_comprobante(%{repartidor: r, detalle: detalle, liquidacion: l}) do
    IO.puts("\n=== COMPROBANTE DE PAGO ===")
    IO.puts("Repartidor: #{r.nombre}   Código: #{r.codigo}")

    if detalle == [] do
      IO.puts("\nNo tuvo días trabajados (sin servicios válidos).")
    else
      IO.puts(
        "\n  " <>
          Formato.alinear_izq("Día", 6) <>
          Formato.alinear_der("Km", 9) <>
          Formato.alinear_der("Servicios", 14) <>
          Formato.alinear_der("Bonificación", 14)
      )

      Enum.each(detalle, fn d ->
        IO.puts(
          "  " <>
            Formato.alinear_izq(d.dia, 6) <>
            Formato.alinear_der(Formato.kilometros(d.kilometros), 9) <>
            Formato.alinear_der(Formato.pesos(d.valor_servicios), 14) <>
            Formato.alinear_der(Formato.pesos(d.bonificacion), 14)
        )
      end)
    end

    IO.puts("\n  Suma valor de servicios:  #{Formato.pesos(l.valor_servicios)}")
    IO.puts("  Suma de bonificaciones:   #{Formato.pesos(l.bonificaciones)}")
    IO.puts("  Descuento por alquiler:   #{Formato.pesos(l.alquiler)}")
    IO.puts("  NETO A PAGAR:             #{Formato.pesos(l.neto)}")
  end
end
