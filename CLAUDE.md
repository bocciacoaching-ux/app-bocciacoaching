# Instrucciones para Claude

## Convención de nombres de ramas

- Crear siempre las ramas nuevas a partir de `main`.
- Formato: `feature/<n>-<resumen-corto>`
  - `<n>`: número consecutivo de cambio (1, 2, 3...). Antes de crear una rama,
    revisar las ramas existentes (`git ls-remote --heads origin`) y usar el
    siguiente número.
  - `<resumen-corto>`: pocas palabras en kebab-case, sin tildes ni ñ, que
    describan lo que se va a trabajar (p. ej. `feature/1-onboarding-nuevos-pasos`).
- Añadir también un pequeño resumen del trabajo de la rama en su descripción
  (`git branch --edit-description`) y en el primer commit / PR.

## Registro de ramas

| # | Rama | Resumen |
|---|------|---------|
| 1 | `feature/1-onboarding` | Cambios en el onboarding (resumen pendiente de definir) |
