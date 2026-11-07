# Adapters de stack

Cada app de `.claude/metodologia.json` declara un `stack`. El hook carga `adapters/<stack>.sh`,
que define dos funciones. Ambas corren **dentro del directorio de la app**, con paths relativos a ella.

| Función | Recibe | Devuelve |
|---|---|---|
| `adapter_lint <archivo>` | archivo editado | `0` ok o no aplica · `≠0` quedan errores (stdout/stderr = detalle) |
| `adapter_tests <archivos…>` | archivos cambiados de la app | `0` ok o sin tests · `1` fallan · `3` problema de entorno (no bloquea) |

`app_cfg <campo>` lee campos de la app actual. Para agregar un stack, copiá `custom.sh` y adaptalo.
