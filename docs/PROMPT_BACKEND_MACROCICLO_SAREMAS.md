# 🧠 Prompt — Implementación del Backend para Manejo de Macrociclos y Evaluación SAREMAS+

> **Proyecto:** Boccia Coaching App  
> **API Base:** `https://bocciacoachingapi.onrender.com/api`  
> **Stack Backend existente:** ASP.NET (inferido por la convención de controladores)  
> **Stack Frontend:** Flutter (Dart) con Provider  
> **Fecha:** Marzo 2026

---

## 1. Contexto General

La **Boccia Coaching App** es una aplicación de entrenamiento y evaluación deportiva para boccia paralímpica. Actualmente el backend soporta:

| Módulo | Controlador API | Estado |
|--------|----------------|--------|
| Autenticación / Usuarios | `/api/User/*` | ✅ Implementado |
| Equipos | `/api/Team/*` | ✅ Implementado |
| Evaluación de Fuerza | `/api/AssessStrength/*` | ✅ Implementado |
| Evaluación de Dirección | `/api/AssessDirection/*` | ✅ Implementado |
| Estadísticas | `/api/Statistics/*` | ✅ Implementado |
| Suscripciones | `/api/Subscription/*` | ✅ Implementado |
| Notificaciones | `/api/Notification/*` | ✅ Implementado |
| Email | `/api/Email/*` | ✅ Implementado |
| **Macrociclos** | — | ❌ Solo persistencia local (SharedPreferences) |
| **Evaluación SAREMAS+** | — | ❌ Solo persistencia local (en memoria) |

Se necesita implementar el backend (API REST) para los dos módulos faltantes: **Macrociclos** y **Evaluación SAREMAS+**, siguiendo los mismos patrones y convenciones del backend existente.

---

## 2. Módulo de Macrociclos

### 2.1 Descripción funcional

Un **macrociclo** es un plan de entrenamiento deportivo a largo plazo (típicamente un año o temporada) asociado a un atleta. Se compone jerárquicamente de:

```
Macrociclo
 ├── Eventos (competencias, concentraciones, evaluaciones, descansos)
 ├── Períodos / Etapas (Preparatorio General, Preparatorio Especial, Competitivo, Transición)
 ├── Mesociclos (bloques de ~4 semanas agrupados por período)
 └── Microciclos (semanas individuales con distribución de entrenamiento)
```

Actualmente la app Flutter calcula toda esta estructura en el frontend (`MacrocycleProvider.buildMacrocycle`) y la persiste en `SharedPreferences`. Se necesita migrar a persistencia en servidor.

### 2.2 Modelo de datos — Entidades

#### `Macrocycle`
| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | `string` (GUID) | Identificador único |
| `athleteId` | `int` | FK al atleta |
| `athleteName` | `string` | Nombre del atleta (desnormalizado para consultas rápidas) |
| `name` | `string` | Nombre del macrociclo (ej: "Temporada 2026") |
| `startDate` | `DateTime` | Fecha de inicio (normalizada al lunes) |
| `endDate` | `DateTime` | Fecha de fin |
| `notes` | `string?` | Notas opcionales |
| `coachId` | `int` | FK al entrenador que lo creó |
| `teamId` | `int` | FK al equipo |
| `createdAt` | `DateTime` | Fecha de creación |
| `updatedAt` | `DateTime?` | Última modificación |

#### `MacrocycleEvent`
| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | `string` (GUID) | Identificador único |
| `macrocycleId` | `string` | FK al macrociclo padre |
| `name` | `string` | Nombre del evento |
| `type` | `enum` | `competencia`, `concentracion`, `evaluacion`, `descanso`, `campus` |
| `startDate` | `DateTime` | Inicio del evento |
| `endDate` | `DateTime` | Fin del evento |
| `location` | `string?` | Ubicación |
| `notes` | `string?` | Notas |

#### `MacrocyclePeriod`
| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | `int` (auto) | PK |
| `macrocycleId` | `string` | FK al macrociclo |
| `name` | `string` | Nombre de la etapa |
| `type` | `enum` | `preparatorioGeneral`, `preparatorioEspecial`, `competitivo`, `transicion` |
| `startDate` | `DateTime` | Inicio del período |
| `endDate` | `DateTime` | Fin del período |
| `weeks` | `int` | Duración en semanas |

#### `Mesocycle`
| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | `int` (auto) | PK |
| `macrocycleId` | `string` | FK al macrociclo |
| `number` | `int` | Número ordinal (1, 2, 3…) |
| `name` | `string` | Nombre descriptivo (ej: "Meso 1 – Desarrollador") |
| `type` | `enum` | `introductorio`, `desarrollador`, `estabilizador`, `competitivo`, `recuperacion`, `precompetitivo` |
| `startDate` | `DateTime` | Inicio |
| `endDate` | `DateTime` | Fin |
| `weeks` | `int` | Duración en semanas |
| `objective` | `string?` | Objetivo del mesociclo |

#### `Microcycle`
| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | `int` (auto) | PK |
| `macrocycleId` | `string` | FK al macrociclo |
| `number` | `int` | Número ordinal de la semana |
| `weekNumber` | `int` | Número de la semana del año |
| `startDate` | `DateTime` | Lunes de la semana |
| `endDate` | `DateTime` | Domingo de la semana |
| `type` | `enum` | `ordinario`, `choque`, `activacion`, `competitivo`, `recuperacion`, `descarga`, `evaluacion` |
| `periodName` | `string?` | Nombre del período al que pertenece |
| `mesocycleName` | `string?` | Nombre del mesociclo al que pertenece |
| `hasPeakPerformance` | `bool` | Si es semana de pico de rendimiento |
| `trainingDistribution` | `JSON object` | Distribución porcentual (ver abajo) |

**TrainingDistribution (JSON embebido en Microcycle):**
```json
{
  "fisicaGeneral": 0.15,
  "fisicaEspecial": 0.15,
  "tecnica": 0.20,
  "tactica": 0.20,
  "teorica": 0.20,
  "psicologica": 0.10
}
```

### 2.3 Endpoints requeridos — Controlador `MacrocycleController`

Siguiendo la convención del backend existente (`AssessStrength`, `AssessDirection`):

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `POST` | `/api/Macrocycle/Create` | Crea un macrociclo completo (con eventos). El backend calcula períodos, mesociclos y microciclos. |
| `GET` | `/api/Macrocycle/GetByAthlete/{athleteId}` | Obtiene todos los macrociclos de un atleta |
| `GET` | `/api/Macrocycle/GetByTeam/{teamId}` | Obtiene todos los macrociclos de un equipo |
| `GET` | `/api/Macrocycle/GetById/{macrocycleId}` | Obtiene un macrociclo completo con todas sus sub-entidades |
| `PUT` | `/api/Macrocycle/Update` | Actualiza un macrociclo (recalcula períodos, mesociclos y microciclos si cambian fechas/eventos) |
| `DELETE` | `/api/Macrocycle/Delete/{macrocycleId}` | Elimina un macrociclo y todas sus sub-entidades (cascade) |
| `POST` | `/api/Macrocycle/AddEvent` | Agrega un evento al macrociclo y recalcula la estructura |
| `PUT` | `/api/Macrocycle/UpdateEvent` | Actualiza un evento existente |
| `DELETE` | `/api/Macrocycle/DeleteEvent/{eventId}` | Elimina un evento y recalcula |
| `PUT` | `/api/Macrocycle/UpdateMicrocycle` | Actualiza un microciclo individual (distribución de entrenamiento, pico de rendimiento, etc.) |
| `GET` | `/api/Macrocycle/GetCoachMacrocycles/{coachId}` | Obtiene todos los macrociclos creados por un coach |
| `POST` | `/api/Macrocycle/Duplicate/{macrocycleId}` | Duplica un macrociclo para otro atleta o período |

### 2.4 Lógica de cálculo en el backend

El backend debe replicar la lógica que actualmente reside en `MacrocycleProvider.buildMacrocycle`:

1. **Microciclos:** Generar una semana (lunes a domingo) por cada 7 días entre `startDate` y `endDate`. Asignar tipo según los eventos que caen en esa semana.

2. **Períodos:** Distribución automática basada en los eventos de competencia:
   - Inicio → 2 semanas antes de la primera competencia = **Preparatorio General**
   - 2 semanas antes de cada competencia = **Preparatorio Especial**
   - Semanas de competencia = **Competitivo**
   - Post última competencia → fin = **Transición**
   - Sin competencias = todo **Preparatorio General**

3. **Mesociclos:** Agrupar microciclos en bloques de ~4 semanas alineados a los períodos. Tipo derivado del período padre:
   - Prep. General → Desarrollador
   - Prep. Especial → Pre-competitivo
   - Competitivo → Competitivo
   - Transición → Recuperación

4. **Distribución de entrenamiento:** Asignar automáticamente según el tipo de microciclo (porcentajes predefinidos para: Física General, Física Especial, Técnica, Táctica, Teórica, Psicológica).

### 2.5 Payload de ejemplo — `POST /api/Macrocycle/Create`

**Request:**
```json
{
  "athleteId": 42,
  "athleteName": "Juan Pérez",
  "name": "Temporada 2026",
  "startDate": "2026-01-05T00:00:00",
  "endDate": "2026-12-27T00:00:00",
  "coachId": 1,
  "teamId": 5,
  "notes": "Preparación para Campeonato Nacional",
  "events": [
    {
      "name": "Campeonato Nacional",
      "type": "competencia",
      "startDate": "2026-06-15T00:00:00",
      "endDate": "2026-06-20T00:00:00",
      "location": "Ciudad de Guatemala"
    },
    {
      "name": "Evaluación COA",
      "type": "evaluacion",
      "startDate": "2026-03-10T00:00:00",
      "endDate": "2026-03-12T00:00:00"
    }
  ]
}
```

**Response:** El macrociclo completo con `id`, `periods`, `mesocycles`, `microcycles` calculados.

---

## 3. Módulo de Evaluación SAREMAS+

### 3.1 Descripción funcional

**SAREMAS+** es un protocolo de evaluación integral de boccia que consiste en **28 lanzamientos** organizados en **4 bloques de 7 tiros**, alternando la diagonal de lanzamiento:

| Bloque | Tiros | Diagonal |
|--------|-------|----------|
| 1 | 1–7 | Roja |
| 2 | 8–14 | Azul |
| 3 | 15–21 | Roja |
| 4 | 22–28 | Azul |

Cada lanzamiento evalúa un **componente técnico** fijo predefinido:

```
Bloque 1 (Roja):  Salida, Romper, Arrimar, Empujar A, Sapito Ras, Montar, Penal
Bloque 2 (Azul):  Romper, Arrimar, Empujar F, Romper AE, Apoyar, Empujar A, Penal
Bloque 3 (Roja):  Romper, Arrimar, Empujar A, Empujar LA, Sapito AE, Arrimar, Penal
Bloque 4 (Azul):  Salida, Romper, Arrimar, Empujar A, Arrima R Zona, Libre Entrega, Penal
```

Cada lanzamiento registra:
- **Puntaje** (0–5)
- **Componente técnico** (asignado automáticamente)
- **Diagonal** (Roja o Azul)
- **Tags de fallo** (Fuerza, Dirección, Cadencia, Trayectoria)
- **Observaciones** (texto libre; obligatorio si puntaje ≤ 2)
- **Datos de cancha** (para componente "Salida"): posiciones XY de bola blanca, bola de color, punto de lanzamiento y distancias calculadas

### 3.2 Modelo de datos — Entidades

#### `SaremasEvaluation`
| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | `int` (auto) | PK |
| `description` | `string` | Nombre/descripción de la evaluación |
| `teamId` | `int` | FK al equipo |
| `coachId` | `int` | FK al entrenador |
| `evaluationDate` | `DateTime` | Fecha de la evaluación |
| `state` | `string` | `Active`, `Completed`, `Cancelled` |
| `totalScore` | `int?` | Puntaje total (calculado al completar, máx 140) |
| `averageScore` | `double?` | Promedio por tiro (calculado) |
| `createdAt` | `DateTime` | Fecha de creación |
| `updatedAt` | `DateTime?` | Última modificación |

#### `SaremasAthleteEvaluation`
| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | `int` (auto) | PK |
| `saremasEvalId` | `int` | FK a la evaluación padre |
| `athleteId` | `int` | FK al atleta |
| `athleteName` | `string` | Nombre (desnormalizado) |

#### `SaremasThrow`
| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | `int` (auto) | PK |
| `saremasEvalId` | `int` | FK a la evaluación padre |
| `athleteId` | `int` | FK al atleta |
| `throwNumber` | `int` | Número del tiro (1–28) |
| `diagonal` | `string` | `Roja` o `Azul` |
| `technicalComponent` | `string` | Componente técnico (ej: "Salida", "Romper", "Penal") |
| `scoreObtained` | `int` | Puntaje (0–5) |
| `observations` | `string?` | Observaciones |
| `failureTags` | `string` | Tags separados por coma: `Fuerza,Dirección,Cadencia,Trayectoria` |
| `status` | `bool` | Estado del tiro |
| `whiteBallX` | `double?` | Posición X bola blanca |
| `whiteBallY` | `double?` | Posición Y bola blanca |
| `colorBallX` | `double?` | Posición X bola de color |
| `colorBallY` | `double?` | Posición Y bola de color |
| `estimatedDistance` | `double?` | Distancia estimada entre bolas (metros) |
| `launchPointX` | `double?` | Posición X punto de lanzamiento |
| `launchPointY` | `double?` | Posición Y punto de lanzamiento |
| `distanceToLaunchPoint` | `double?` | Distancia del lanzamiento al jack (metros) |
| `timestamp` | `DateTime` | Momento del registro |

### 3.3 Endpoints requeridos — Controlador `AssessSaremas`

Siguiendo la convención exacta de `AssessStrength` y `AssessDirection`:

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `POST` | `/api/AssessSaremas/AddEvaluation` | Crea una nueva evaluación SAREMAS+ |
| `POST` | `/api/AssessSaremas/AthletesToEvaluated` | Asigna atletas a la evaluación |
| `POST` | `/api/AssessSaremas/AddDetailsToEvaluation` | Registra un lanzamiento individual |
| `GET` | `/api/AssessSaremas/GetActiveEvaluation/{teamId}/{coachId}` | Obtiene la evaluación activa (para reanudar) |
| `PUT` | `/api/AssessSaremas/UpdateState` | Actualiza el estado de la evaluación |
| `POST` | `/api/AssessSaremas/Cancel` | Cancela una evaluación en curso |
| `GET` | `/api/AssessSaremas/GetTeamEvaluations/{teamId}` | Lista todas las evaluaciones SAREMAS+ de un equipo |
| `GET` | `/api/AssessSaremas/GetEvaluationDetails/{saremasEvalId}` | Detalle completo con todos los tiros |
| `GET` | `/api/AssessSaremas/GetEvaluationStatistics/{saremasEvalId}` | Estadísticas desglosadas |
| `GET` | `/api/AssessSaremas/GetAthleteHistory/{athleteId}` | Historial de evaluaciones SAREMAS+ de un atleta |

### 3.4 Payloads de ejemplo

#### `POST /api/AssessSaremas/AddEvaluation`
**Request:**
```json
{
  "description": "SAREMAS+ Marzo 2026",
  "teamId": 5,
  "coachId": 1
}
```
**Response:**
```json
{
  "id": 101,
  "description": "SAREMAS+ Marzo 2026",
  "teamId": 5,
  "coachId": 1,
  "evaluationDate": "2026-03-29T00:00:00",
  "state": "Active"
}
```

#### `POST /api/AssessSaremas/AthletesToEvaluated`
**Request:**
```json
{
  "coachId": 1,
  "athleteId": 42,
  "saremasEvalId": 101
}
```

#### `POST /api/AssessSaremas/AddDetailsToEvaluation`
**Request:**
```json
{
  "throwNumber": 1,
  "diagonal": "Roja",
  "technicalComponent": "Salida",
  "scoreObtained": 4,
  "observations": "",
  "failureTags": "Dirección",
  "status": true,
  "athleteId": 42,
  "saremasEvalId": 101,
  "whiteBallX": 45.2,
  "whiteBallY": 62.8,
  "colorBallX": 47.1,
  "colorBallY": 60.3,
  "estimatedDistance": 0.35,
  "launchPointX": 50.0,
  "launchPointY": 95.0,
  "distanceToLaunchPoint": 3.42
}
```

#### `GET /api/AssessSaremas/GetEvaluationStatistics/{saremasEvalId}`
**Response esperado:**
```json
{
  "evaluationId": 101,
  "totalScore": 98,
  "maxPossibleScore": 140,
  "averageScore": 3.5,
  "throwsCompleted": 28,
  "scoreByDiagonal": {
    "Roja": { "total": 52, "average": 3.71, "count": 14 },
    "Azul": { "total": 46, "average": 3.29, "count": 14 }
  },
  "scoreByComponent": {
    "Salida": { "total": 8, "average": 4.0, "count": 2 },
    "Romper": { "total": 18, "average": 3.6, "count": 5 },
    "Arrimar": { "total": 16, "average": 3.2, "count": 5 },
    "Penal": { "total": 15, "average": 3.75, "count": 4 },
    "...": "..."
  },
  "scoreByBlock": {
    "1": { "total": 26, "average": 3.71 },
    "2": { "total": 24, "average": 3.43 },
    "3": { "total": 25, "average": 3.57 },
    "4": { "total": 23, "average": 3.29 }
  },
  "failureTagFrequency": {
    "Fuerza": 5,
    "Dirección": 8,
    "Cadencia": 3,
    "Trayectoria": 4
  },
  "salidaMetrics": {
    "averageDistance": 0.42,
    "averageLaunchDistance": 3.15,
    "throwsWithCourtData": 2
  }
}
```

---

## 4. Endpoints de Estadísticas cruzadas (ampliación)

Agregar al controlador `Statistics` existente:

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `GET` | `/api/Statistics/SaremasTeamStats/{teamId}` | Estadísticas SAREMAS+ por equipo |
| `GET` | `/api/Statistics/SaremasAthleteStats/{athleteId}` | Evolución SAREMAS+ de un atleta |
| `GET` | `/api/Statistics/MacrocycleProgress/{macrocycleId}` | Progreso del macrociclo (semana actual, evaluaciones realizadas) |
| `GET` | `/api/Statistics/AthleteFullDashboard/{athleteId}` | Dashboard unificado: Fuerza + Dirección + SAREMAS+ + Macrociclo |

---

## 5. Reglas de negocio clave

### Macrociclos
1. Un atleta puede tener **múltiples macrociclos** pero NO solapados en fechas.
2. El `startDate` se normaliza al lunes más reciente.
3. Al agregar/eliminar/modificar un evento, el backend **recalcula automáticamente** períodos, mesociclos y microciclos.
4. Solo el coach creador o un admin pueden editar/eliminar un macrociclo.
5. La distribución de entrenamiento de cada microciclo tiene un valor por defecto según su tipo pero puede ser modificada manualmente (la suma de porcentajes debe ser = 1.0).

### SAREMAS+
1. Solo puede haber **una evaluación activa** por equipo/coach a la vez (mismo patrón que Strength y Direction).
2. Cada evaluación tiene exactamente **28 tiros**.
3. El componente técnico de cada tiro está **predeterminado** (no lo elige el usuario).
4. Si el puntaje es ≤ 2, las observaciones son **obligatorias** (validación backend).
5. Los datos de cancha (`whiteBallX`, `colorBallX`, etc.) solo aplican para el componente "Salida" y son opcionales.
6. Al completar los 28 tiros, el estado cambia automáticamente a `Completed` y se calculan las estadísticas.

---

## 6. Consideraciones técnicas

### Base de datos
- Usar **Entity Framework Core** con migraciones.
- Relaciones: Macrocycle → Events, Periods, Mesocycles, Microcycles (1:N con cascade delete).
- SaremasEvaluation → SaremasAthleteEvaluation, SaremasThrow (1:N con cascade delete).
- Índices en: `athleteId`, `teamId`, `coachId`, `macrocycleId`, `saremasEvalId`.

### Autenticación
- Usar el mismo esquema JWT Bearer que los controladores existentes.
- Validar que el coach pertenece al equipo antes de crear/modificar datos.

### Validaciones
- Fechas: `endDate > startDate`, eventos dentro del rango del macrociclo.
- Puntajes SAREMAS+: rango [0, 5].
- Distribución de entrenamiento: suma = 1.0 (con tolerancia de ±0.01).
- No permitir duplicar `throwNumber` para un mismo atleta en la misma evaluación.

### Respuesta estándar
Seguir el formato de respuesta existente:
```json
{
  "success": true,
  "data": { ... },
  "message": "Operación exitosa"
}
```
En caso de error:
```json
{
  "success": false,
  "data": null,
  "message": "Descripción del error"
}
```

---

## 7. Orden de implementación sugerido

### Fase 1 — SAREMAS+ (prioridad alta)
1. Crear entidades y migraciones para `SaremasEvaluation`, `SaremasAthleteEvaluation`, `SaremasThrow`.
2. Implementar `AssessSaremasController` con los endpoints CRUD.
3. Implementar lógica de estadísticas.
4. Tests unitarios.

### Fase 2 — Macrociclos
1. Crear entidades y migraciones para `Macrocycle`, `MacrocycleEvent`, `MacrocyclePeriod`, `Mesocycle`, `Microcycle`.
2. Implementar la lógica de cálculo (portar de Dart a C#).
3. Implementar `MacrocycleController` con endpoints CRUD.
4. Endpoint de recálculo automático al modificar eventos.
5. Tests unitarios.

### Fase 3 — Integración con estadísticas
1. Agregar endpoints de estadísticas cruzadas.
2. Dashboard unificado por atleta.

### Fase 4 — Integración con el frontend Flutter
1. Crear `SaremasService` en `lib/core/services/` (similar a `AssessStrengthService`).
2. Crear `MacrocycleService` en `lib/core/services/`.
3. Agregar endpoints a `ApiEndpoints`.
4. Actualizar `SaremasProvider` para usar la API en vez de IDs locales.
5. Actualizar `MacrocycleProvider` para sincronizar con el servidor (mantener fallback local).

---

## 8. Referencia de patrones existentes (para mantener consistencia)

### Servicio de ejemplo (Strength — Flutter side)
```
AssessStrengthService
  ├── addEvaluation(description, teamId, coachId)
  ├── addAthleteToEvaluation(coachId, athleteId, assessStrengthId)
  ├── addDetailsToEvaluation(boxNumber, throwOrder, targetDistance, scoreObtained, ...)
  ├── getActiveEvaluation(teamId, coachId)
  ├── updateState(id, evaluationDate, description, teamId, state)
  ├── cancel(assessStrengthId, coachId, reason)
  ├── getTeamEvaluations(teamId)
  ├── getEvaluationStatistics(assessStrengthId)
  └── getEvaluationDetails(assessStrengthId)
```

El nuevo `AssessSaremasService` debe seguir **exactamente** esta estructura, sustituyendo los campos específicos de fuerza por los de SAREMAS+.

### Convención de nombres de controladores
- Singular: `AssessStrength`, `AssessDirection` → `AssessSaremas`
- Singular: `Macrocycle`

---

## 9. Diagrama de relaciones (ER simplificado)

```
┌─────────────┐      ┌──────────────────┐
│    Team      │─────<│   Macrocycle      │
└─────────────┘      │   - athleteId     │
                     │   - coachId       │
┌─────────────┐      │   - teamId        │
│   Athlete    │─────<│                  │
└─────────────┘      └──────┬───────────┘
                            │ 1:N
          ┌─────────────────┼─────────────────┐
          │                 │                 │
   ┌──────▼──────┐  ┌──────▼──────┐  ┌──────▼──────┐
   │MacrocycleEvent│ │MacrocyclePeriod│ │  Mesocycle  │
   └─────────────┘  └─────────────┘  └─────────────┘
                                            │ 1:N
                                     ┌──────▼──────┐
                                     │  Microcycle  │
                                     └─────────────┘

┌─────────────┐      ┌──────────────────────┐
│    Team      │─────<│ SaremasEvaluation    │
└─────────────┘      │   - coachId           │
                     │   - teamId            │
┌─────────────┐      └──────┬───────────────┘
│   Coach      │─────<       │ 1:N
└─────────────┘      ┌──────▼───────────────┐
                     │SaremasAthleteEvaluation│
┌─────────────┐      │   - athleteId         │
│   Athlete    │─────<└──────────────────────┘
└─────────────┘              │ 1:N
                     ┌──────▼───────────────┐
                     │    SaremasThrow       │
                     │   - throwNumber (1-28)│
                     │   - diagonal          │
                     │   - technicalComponent│
                     │   - scoreObtained     │
                     │   - failureTags       │
                     │   - datos de cancha   │
                     └──────────────────────┘
```

---

> **Nota:** Este documento describe la especificación completa para el equipo de backend. La implementación del frontend (Flutter) ya existe parcialmente y se adaptará para consumir estos endpoints una vez estén disponibles.
