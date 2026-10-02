# Integrantes:
# - Alejandro García Cadavid
# - Daniela Naranjo Sánchez
# - Luisa Fda Salazar González

defmodule Datos do
  @moduledoc """
  Datos del grupo. Solo contiene datos, sin lógica.

  Resumen:
    - 12 repartidores (6 con bicicleta). M11 y M12 no tienen servicios válidos.
    - 4 zonas.
    - 99 servicios válidos en Slos 6 días.
    - 17 servicios inválidos (mínimo 2 por cada motivo, algunos con tipos erróneos).

  Casos de borde incluidos: 45 km exactos, retraso 0, 10, 30, -30 y 180,
  80 km exactos en un día (M03, día 2), 79.5 km (M07, día 5, sin bonificación),
  día de exactamente 500 km (día 6), empates en R5 y un repartidor con
  menos de 3 servicios (M10) para R6.
  """

  @doc "Lista de repartidores."
  def repartidores do
    [
      %{codigo: "M01", nombre: "Ana Torres", bicicleta: true},
      %{codigo: "M02", nombre: "David López", bicicleta: false},
      %{codigo: "M03", nombre: "Camila Restrepo", bicicleta: true},
      %{codigo: "M04", nombre: "Juan Ríos", bicicleta: false},
      %{codigo: "M05", nombre: "Laura Gómez", bicicleta: true},
      %{codigo: "M06", nombre: "Sergio Mejía", bicicleta: false},
      %{codigo: "M07", nombre: "Paula Cardona", bicicleta: true},
      %{codigo: "M08", nombre: "Mateo Salazar", bicicleta: false},
      %{codigo: "M09", nombre: "Valeria Duque", bicicleta: true},
      %{codigo: "M10", nombre: "Esteban Giraldo", bicicleta: false},
      %{codigo: "M11", nombre: "Daniela Ospina", bicicleta: false},
      %{codigo: "M12", nombre: "Tomás Arias", bicicleta: true}
    ]
  end

  @doc "Lista de zonas con su área en km²."
  def zonas do
    [
      %{id: "Z1", nombre: "Centro", area: 6.5},
      %{id: "Z2", nombre: "Norte", area: 10.2},
      %{id: "Z3", nombre: "Sur", area: 8.8},
      %{id: "Z4", nombre: "Oriente", area: 13.25}
    ]
  end

  @doc "Servicios consolidados (válidos e inválidos mezclados, como llegan del campo)."
  def servicios do
    [
      # Día 1
      %{repartidor: "M02", zona: "Z2", dia: 1, kilometros: 10.5, retraso: 8},
      %{repartidor: "M04", zona: "Z3", dia: 1, kilometros: 45, retraso: 0},
      %{repartidor: "M06", zona: "Z4", dia: 1, kilometros: 20.5, retraso: 6},
      %{repartidor: "M08", zona: "Z1", dia: 1, kilometros: 29.5, retraso: 6},
      %{repartidor: "M01", zona: "Z2", dia: 1, kilometros: 43, retraso: 0},
      %{repartidor: "M03", zona: "Z3", dia: 1, kilometros: 45, retraso: -5},
      %{repartidor: "M05", zona: "Z4", dia: 1, kilometros: 45, retraso: 35},
      %{repartidor: "M07", zona: "Z1", dia: 1, kilometros: 29.5, retraso: 15},
      %{repartidor: "M09", zona: "Z2", dia: 1, kilometros: 15, retraso: 28},
      %{repartidor: "M02", zona: "Z3", dia: 1, kilometros: 18.5, retraso: -12},
      %{repartidor: "M04", zona: "Z4", dia: 1, kilometros: 20, retraso: 35},
      %{repartidor: "M06", zona: "Z1", dia: 1, kilometros: 32, retraso: 4},
      %{repartidor: "M08", zona: "Z2", dia: 1, kilometros: 20, retraso: -12},
      %{repartidor: "M01", zona: "Z3", dia: 1, kilometros: 45, retraso: 10},
      %{repartidor: "M03", zona: "Z4", dia: 1, kilometros: 15, retraso: 18},
      %{repartidor: "M05", zona: "Z1", dia: 1, kilometros: 45, retraso: 2},
      %{repartidor: "M07", zona: "Z2", dia: 1, kilometros: 34.5, retraso: 2},
      %{repartidor: "M09", zona: "Z3", dia: 1, kilometros: 27, retraso: 10},

      # Día 2
      %{repartidor: "M03", zona: "Z3", dia: 2, kilometros: 35, retraso: 15},
      %{repartidor: "M05", zona: "Z4", dia: 2, kilometros: 24, retraso: 0},
      %{repartidor: "M07", zona: "Z1", dia: 2, kilometros: 13, retraso: 10},
      %{repartidor: "M09", zona: "Z2", dia: 2, kilometros: 32.5, retraso: 22},
      %{repartidor: "M10", zona: "Z3", dia: 2, kilometros: 32, retraso: -28},
      %{repartidor: "M04", zona: "Z4", dia: 2, kilometros: 37, retraso: 15},
      %{repartidor: "M06", zona: "Z1", dia: 2, kilometros: 37.5, retraso: 15},
      %{repartidor: "M08", zona: "Z2", dia: 2, kilometros: 12, retraso: 60},
      %{repartidor: "M01", zona: "Z3", dia: 2, kilometros: 34, retraso: -25},
      %{repartidor: "M03", zona: "Z4", dia: 2, kilometros: 45, retraso: 22},
      %{repartidor: "M05", zona: "Z1", dia: 2, kilometros: 13.5, retraso: 0},
      %{repartidor: "M07", zona: "Z2", dia: 2, kilometros: 38, retraso: 45},
      %{repartidor: "M09", zona: "Z3", dia: 2, kilometros: 43, retraso: -5},
      %{repartidor: "M02", zona: "Z4", dia: 2, kilometros: 34, retraso: -18},

      # Día 3
      %{repartidor: "M04", zona: "Z4", dia: 3, kilometros: 15, retraso: -25},
      %{repartidor: "M06", zona: "Z1", dia: 3, kilometros: 33.5, retraso: 31},
      %{repartidor: "M08", zona: "Z2", dia: 3, kilometros: 39, retraso: -5},
      %{repartidor: "M01", zona: "Z3", dia: 3, kilometros: 17.5, retraso: 28},
      %{repartidor: "M03", zona: "Z4", dia: 3, kilometros: 39, retraso: 25},
      %{repartidor: "M05", zona: "Z1", dia: 3, kilometros: 23.5, retraso: 30},
      %{repartidor: "M07", zona: "Z2", dia: 3, kilometros: 15.5, retraso: 60},
      %{repartidor: "M09", zona: "Z3", dia: 3, kilometros: 37, retraso: 15},
      %{repartidor: "M02", zona: "Z4", dia: 3, kilometros: 39, retraso: 12},
      %{repartidor: "M04", zona: "Z3", dia: 3, kilometros: 24.5, retraso: 6},
      %{repartidor: "M06", zona: "Z2", dia: 3, kilometros: 31, retraso: -1},
      %{repartidor: "M08", zona: "Z3", dia: 3, kilometros: 25.5, retraso: 0},
      %{repartidor: "M01", zona: "Z4", dia: 3, kilometros: 39, retraso: 31},
      %{repartidor: "M03", zona: "Z1", dia: 3, kilometros: 31, retraso: 12},
      %{repartidor: "M05", zona: "Z2", dia: 3, kilometros: 34, retraso: 10},
      %{repartidor: "M07", zona: "Z3", dia: 3, kilometros: 21.5, retraso: 15},
      %{repartidor: "M09", zona: "Z4", dia: 3, kilometros: 25.5, retraso: 45},
      %{repartidor: "M02", zona: "Z1", dia: 3, kilometros: 24.5, retraso: 12},

      # Día 4
      %{repartidor: "M05", zona: "Z1", dia: 4, kilometros: 43.5, retraso: 28},
      %{repartidor: "M07", zona: "Z2", dia: 4, kilometros: 13.5, retraso: -30},
      %{repartidor: "M09", zona: "Z3", dia: 4, kilometros: 28, retraso: 12},
      %{repartidor: "M02", zona: "Z4", dia: 4, kilometros: 28.5, retraso: 6},
      %{repartidor: "M04", zona: "Z3", dia: 4, kilometros: 39.5, retraso: -8},
      %{repartidor: "M06", zona: "Z2", dia: 4, kilometros: 15.5, retraso: -1},
      %{repartidor: "M08", zona: "Z3", dia: 4, kilometros: 39.5, retraso: 35},
      %{repartidor: "M01", zona: "Z4", dia: 4, kilometros: 25.5, retraso: 10},
      %{repartidor: "M03", zona: "Z1", dia: 4, kilometros: 39.5, retraso: -5},
      %{repartidor: "M05", zona: "Z2", dia: 4, kilometros: 27.5, retraso: 10},
      %{repartidor: "M07", zona: "Z3", dia: 4, kilometros: 36.5, retraso: -25},
      %{repartidor: "M09", zona: "Z4", dia: 4, kilometros: 43, retraso: -12},
      %{repartidor: "M02", zona: "Z1", dia: 4, kilometros: 15, retraso: -25},

      # Día 5
      %{repartidor: "M10", zona: "Z2", dia: 5, kilometros: 43.5, retraso: -26},
      %{repartidor: "M08", zona: "Z3", dia: 5, kilometros: 18.5, retraso: -3},
      %{repartidor: "M01", zona: "Z4", dia: 5, kilometros: 26.5, retraso: -5},
      %{repartidor: "M03", zona: "Z1", dia: 5, kilometros: 30, retraso: 60},
      %{repartidor: "M05", zona: "Z2", dia: 5, kilometros: 19, retraso: 60},
      %{repartidor: "M07", zona: "Z3", dia: 5, kilometros: 34.5, retraso: 22},
      %{repartidor: "M09", zona: "Z4", dia: 5, kilometros: 29.5, retraso: 2},
      %{repartidor: "M02", zona: "Z1", dia: 5, kilometros: 36, retraso: 15},
      %{repartidor: "M04", zona: "Z2", dia: 5, kilometros: 21, retraso: 10},
      %{repartidor: "M06", zona: "Z3", dia: 5, kilometros: 14, retraso: 8},
      %{repartidor: "M08", zona: "Z2", dia: 5, kilometros: 33.5, retraso: 60},
      %{repartidor: "M01", zona: "Z1", dia: 5, kilometros: 44, retraso: -5},
      %{repartidor: "M03", zona: "Z2", dia: 5, kilometros: 22.5, retraso: 15},
      %{repartidor: "M05", zona: "Z3", dia: 5, kilometros: 29, retraso: 60},
      %{repartidor: "M07", zona: "Z4", dia: 5, kilometros: 45, retraso: -1},
      %{repartidor: "M09", zona: "Z1", dia: 5, kilometros: 21.5, retraso: 8},
      %{repartidor: "M02", zona: "Z2", dia: 5, kilometros: 31.5, retraso: -25},
      %{repartidor: "M04", zona: "Z3", dia: 5, kilometros: 18, retraso: -8},
      %{repartidor: "M06", zona: "Z4", dia: 5, kilometros: 42.5, retraso: 8},

      # Día 6
      %{repartidor: "M07", zona: "Z3", dia: 6, kilometros: 18, retraso: 10},
      %{repartidor: "M09", zona: "Z4", dia: 6, kilometros: 17, retraso: 180},
      %{repartidor: "M02", zona: "Z1", dia: 6, kilometros: 35.5, retraso: 4},
      %{repartidor: "M04", zona: "Z2", dia: 6, kilometros: 35.5, retraso: 10},
      %{repartidor: "M06", zona: "Z3", dia: 6, kilometros: 14.5, retraso: 25},
      %{repartidor: "M08", zona: "Z2", dia: 6, kilometros: 14.5, retraso: 0},
      %{repartidor: "M01", zona: "Z1", dia: 6, kilometros: 45, retraso: 30},
      %{repartidor: "M03", zona: "Z2", dia: 6, kilometros: 33.5, retraso: 31},
      %{repartidor: "M05", zona: "Z3", dia: 6, kilometros: 30.5, retraso: -12},
      %{repartidor: "M07", zona: "Z4", dia: 6, kilometros: 44.5, retraso: 18},
      %{repartidor: "M09", zona: "Z1", dia: 6, kilometros: 33, retraso: 8},
      %{repartidor: "M02", zona: "Z2", dia: 6, kilometros: 18.5, retraso: -18},
      %{repartidor: "M04", zona: "Z3", dia: 6, kilometros: 45, retraso: -1},
      %{repartidor: "M06", zona: "Z4", dia: 6, kilometros: 44.5, retraso: 28},
      %{repartidor: "M08", zona: "Z1", dia: 6, kilometros: 23.5, retraso: -3},
      %{repartidor: "M01", zona: "Z2", dia: 6, kilometros: 21, retraso: -18},
      %{repartidor: "M03", zona: "Z3", dia: 6, kilometros: 26, retraso: 28},

      # ---- Inválidos: :repartidor_desconocido (3, uno incumple además otras reglas)
      %{repartidor: "M99", zona: "Z1", dia: 2, kilometros: 20, retraso: 5},
      %{repartidor: "m01", zona: "Z2", dia: 3, kilometros: 18, retraso: 0},
      %{repartidor: "M98", zona: "Z8", dia: 9, kilometros: 99, retraso: 999},

      # ---- Inválidos: :zona_desconocida (2)
      %{repartidor: "M02", zona: "Z9", dia: 1, kilometros: 15, retraso: 3},
      %{repartidor: "M04", zona: nil, dia: 2, kilometros: 22, retraso: 5},

      # ---- Inválidos: :dia_invalido (4, uno incumple además otras reglas)
      %{repartidor: "M12", zona: "Z1", dia: 7, kilometros: 20, retraso: 5},
      %{repartidor: "M06", zona: "Z2", dia: "3", kilometros: 25, retraso: 5},
      %{repartidor: "M07", zona: "Z3", dia: 2.5, kilometros: 30, retraso: 0},
      %{repartidor: "M02", zona: "Z1", dia: 0, kilometros: -1, retraso: 500},

      # ---- Inválidos: :kilometros_fuera_de_rango (4)
      %{repartidor: "M08", zona: "Z4", dia: 4, kilometros: 46, retraso: 5},
      %{repartidor: "M09", zona: "Z1", dia: 5, kilometros: 0, retraso: 0},
      %{repartidor: "M01", zona: "Z2", dia: 2, kilometros: "abc", retraso: 3},
      %{repartidor: "M03", zona: "Z3", dia: 6, kilometros: -5, retraso: 10},

      # ---- Inválidos: :retraso_invalido (4)
      %{repartidor: "M05", zona: "Z4", dia: 1, kilometros: 20, retraso: 181},
      %{repartidor: "M06", zona: "Z1", dia: 3, kilometros: 12, retraso: -31},
      %{repartidor: "M07", zona: "Z2", dia: 4, kilometros: 18, retraso: nil},
      %{repartidor: "M08", zona: "Z3", dia: 5, kilometros: 22, retraso: "x"}
    ]
  end
end
