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

## Antes de subir cambios a GitHub

- Siempre, antes de cada `git push`, revisar si `main` tiene cambios nuevos
  (por ejemplo, de Oscar):
  1. `git fetch --depth=50 origin main`
  2. `git log --oneline HEAD..origin/main` para ver los commits nuevos.
  3. Si hay cambios, informar a Jesica qué cambió y traerlos a la rama
     (rebase sobre `origin/main`), resolviendo conflictos antes de subir.
- Antes de subir, mostrar los cambios a Jesica en la vista previa (artefacto)
  para que los revise.

## Registro de ramas

| # | Rama | Resumen |
|---|------|---------|
| 1 | `feature/1-onboarding` | Cambios en el onboarding (resumen pendiente de definir) |
