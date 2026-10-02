# Integrantes:
# - Alejandro García Cadavid
# - Daniela Naranjo Sánchez
# - Luisa Fda Salazar González

defmodule Formato do
  @moduledoc """
  Funciones PURAS para dar formato a números y textos. No hacen entrada/salida.
  """

  @doc """
  Formatea un entero como pesos con separador de miles.

  ## Ejemplo

      iex> Formato.pesos(1234567)
      "$1.234.567"
  """
  def pesos(valor) when is_integer(valor) do
    signo = if valor < 0, do: "-", else: ""
    "#{signo}$#{valor |> abs() |> Integer.to_string() |> separar_miles()}"
  end

  @doc "Convierte un número (entero o decimal) a texto con `cifras` decimales."
  def decimal(valor, cifras) when is_number(valor) do
    :erlang.float_to_binary(valor / 1, decimals: cifras)
  end

  @doc "Kilómetros con un decimal."
  def kilometros(valor), do: decimal(valor, 1)

  @doc "Alinea el texto a la izquierda rellenando con espacios hasta `ancho`."
  def alinear_izq(texto, ancho), do: String.pad_trailing(to_string(texto), ancho)

  @doc "Alinea el texto a la derecha rellenando con espacios hasta `ancho`."
  def alinear_der(texto, ancho), do: String.pad_leading(to_string(texto), ancho)

  # Agrupa los dígitos de a tres (de derecha a izquierda) separados por punto.
  defp separar_miles(digitos) do
    digitos
    |> String.reverse()
    |> String.graphemes()
    |> Enum.chunk_every(3)
    |> Enum.map(&Enum.join/1)
    |> Enum.join(".")
    |> String.reverse()
  end
end
