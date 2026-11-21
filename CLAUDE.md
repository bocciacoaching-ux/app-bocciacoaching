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

## Proceso de trabajo (acordado con Jesica)

1. **Todo se trabaja en local, en la rama `demo-local`.** Se parte de
   `origin/main` y encima van, en commits separados:
   - herramientas del modo demo (`lib/demo/`, `demo-tools/`, este CLAUDE.md);
   - un commit (o varios) por cada cambio en curso, con un mensaje que diga
     claramente qué cambio es.
   Nada de esto se sube como rama de cambios ni a `main`.
2. **Se prueba en el demo del artefacto** (https://claude.ai/artifact/UDpEk7CNziZvTjMfQZNnJC):
   `demo-tools/build_demo.sh` compila `lib/demo/demo_main.dart` (API simulada,
   usuarios `coach@demo.com` / `atleta@demo.com`, contraseña `demo1234`) y se
   republica el artefacto. El visor tiene escritorio 1440, iPad y móvil.
3. **Respaldo:** después de cada avance, subir `demo-local` a la rama privada
   del mismo nombre (`git push --force-with-lease origin demo-local`). Es la
   única rama que se sube sin aprobación; no es una rama de cambios.
   - **Cambios descartados:** cuando Jesica descarte un cambio, quitar sus
     commits de `demo-local` (rebase eliminándolos, no un revert), revisar que
     no quede rastro (archivos, datos de demo), recompilar y republicar el
     demo, y subir `demo-local` con `--force-with-lease` para que la rama
     privada tampoco lo conserve.
4. **Cada día (8:00 hora Colombia) revisar `main`:** `git fetch --depth=50
   origin main` y `git log --oneline demo-local..origin/main`. Si Oscar subió
   cambios: rebase de `demo-local` sobre `origin/main`, recompilar y
   republicar el demo, y avisar a Jesica qué cambió. Si alguno de esos cambios
   toca pantallas en las que estamos trabajando, decirle cuál es el cambio y
   conservar nuestros cambios al resolver conflictos.
5. **Solo cuando Jesica diga que un cambio está aprobado:** revisar `main`,
   crear la rama `feature/<n>-<resumen>` desde `origin/main`, llevar solo los
   commits de ese cambio (nunca `lib/demo/`, `demo-tools/` ni las
   herramientas), y subirla.

## Antes de subir cambios a GitHub

- Siempre, antes de cada `git push`, revisar si `main` tiene cambios nuevos
  (por ejemplo, de Oscar):
  1. `git fetch --depth=50 origin main`
  2. `git log --oneline HEAD..origin/main` para ver los commits nuevos.
  3. Si hay cambios, informar a Jesica qué cambió y traerlos a la rama
     (rebase sobre `origin/main`), resolviendo conflictos antes de subir.
- Antes de subir, mostrar los cambios a Jesica en la vista previa (artefacto)
  y esperar su aprobación.

## Registro de ramas

| # | Rama | Resumen |
|---|------|---------|
| 1 | `feature/1-onboarding` | Cambios en el onboarding (resumen pendiente de definir) |
