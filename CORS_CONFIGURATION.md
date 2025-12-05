# Configuración CORS - Truek API

## 🌐 CORS (Cross-Origin Resource Sharing)

CORS está configurado para permitir requests desde tus dominios de frontend en producción y desarrollo.

## ✅ Dominios Configurados

### Producción
```
https://www.truek.xyz
https://truek.xyz
```

### Desarrollo (solo en entorno development/test)
```
http://localhost:3000
http://localhost:5173  (Vite)
http://localhost:4173  (Vite preview)
http://127.0.0.1:3000
http://127.0.0.1:5173
http://127.0.0.1:4173
```

## 🔧 Configuración Actual

La configuración se encuentra en `config/initializers/cors.rb`:

### Características de Producción:
- ✅ Solo dominios específicos (truek.xyz)
- ✅ Credentials habilitado (permite cookies/auth)
- ✅ Cache de preflight (24 horas)
- ✅ Todos los métodos HTTP necesarios
- ✅ Header Authorization expuesto

### Características de Desarrollo:
- ✅ Múltiples puertos localhost
- ✅ Sin credentials (más flexible)
- ✅ Solo activo en development/test

## 📡 Métodos HTTP Permitidos

```
GET, POST, PUT, PATCH, DELETE, OPTIONS, HEAD
```

## 🔑 Headers Permitidos

- Todos los headers (`headers: :any`)
- Header `Authorization` expuesto para el frontend

## 🚀 Testing CORS

### Desde tu Frontend en Producción:

```javascript
// Ejemplo con fetch
fetch('https://api.truek.xyz/api/v1/auth/google', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  credentials: 'include',  // Importante para cookies
  body: JSON.stringify({ token: googleToken })
})
.then(res => res.json())
.then(data => console.log(data));
```

### Verificar Headers CORS:

Puedes verificar que CORS esté funcionando viendo estos headers en la respuesta:

```
Access-Control-Allow-Origin: https://truek.xyz
Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS, HEAD
Access-Control-Allow-Headers: *
Access-Control-Expose-Headers: Authorization
Access-Control-Allow-Credentials: true
Access-Control-Max-Age: 86400
```

## 🛠️ Agregar Más Dominios

Si necesitas agregar más dominios (staging, otros subdominios):

**Edita `config/initializers/cors.rb`:**

```ruby
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'https://www.truek.xyz', 
            'https://truek.xyz',
            'https://staging.truek.xyz',  # Nuevo
            'https://admin.truek.xyz'      # Nuevo

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ['Authorization'],
      credentials: true,
      max_age: 86400
  end
end
```

**Luego reinicia el servidor:**
```bash
rails restart
# o
touch tmp/restart.txt
```

## 🔒 Seguridad

### ✅ Buenas Prácticas Implementadas:

1. **Whitelist específica en producción**: Solo dominios conocidos
2. **Credentials solo en producción**: Mayor seguridad
3. **Cache de preflight**: Reduce requests OPTIONS
4. **Separación por entorno**: Configuración diferente según environment

### ⚠️ Evita en Producción:

```ruby
# ❌ NO hacer esto en producción
origins '*'  # Permite CUALQUIER dominio
```

## 🐛 Troubleshooting

### Error: "CORS policy blocked"

**Problema**: El navegador bloquea el request.

**Soluciones**:

1. **Verifica que el dominio esté en la lista**:
   - Revisa `config/initializers/cors.rb`
   - Asegúrate de usar HTTPS en producción

2. **Verifica el header Origin**:
   - Abre DevTools → Network → selecciona el request
   - Verifica que el header `Origin` coincida exactamente

3. **Reinicia el servidor** después de cambiar CORS:
   ```bash
   rails restart
   ```

4. **Verifica el método HTTP**:
   - Asegúrate que el método esté en la lista permitida

### Error: "Credentials flag is true"

**Problema**: Frontend envía credentials pero backend no las permite.

**Solución**:
```javascript
// Frontend
fetch(url, {
  credentials: 'include'  // Asegúrate de usar esto
})
```

```ruby
# Backend (config/initializers/cors.rb)
credentials: true  # Debe estar presente
```

### Preflight Request Falla

**Problema**: Request OPTIONS falla.

**Solución**:
- Asegúrate que `options` esté en la lista de métodos
- Verifica que el dominio esté permitido
- Revisa logs del servidor: `tail -f log/development.log`

## 📊 Verificar en Production

### Comando cURL:

```bash
# Test preflight request
curl -X OPTIONS https://api.truek.xyz/api/v1/auth/google \
  -H "Origin: https://truek.xyz" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: Content-Type" \
  -v

# Test real request
curl -X POST https://api.truek.xyz/api/v1/auth/google \
  -H "Origin: https://truek.xyz" \
  -H "Content-Type: application/json" \
  -d '{"token":"test"}' \
  -v
```

### Desde el Navegador:

```javascript
// Abre la consola del navegador en https://truek.xyz y ejecuta:
fetch('https://api.truek.xyz/api/v1/users/me', {
  headers: {
    'Authorization': 'Bearer tu_token_jwt'
  }
})
.then(res => {
  console.log('CORS Headers:', res.headers);
  return res.json();
})
.then(data => console.log('Data:', data))
.catch(err => console.error('Error:', err));
```

## 🌍 Variables de Entorno (Opcional)

Si quieres hacer los dominios configurables por variables de entorno:

```ruby
# config/initializers/cors.rb
allowed_origins = ENV['CORS_ALLOWED_ORIGINS']&.split(',') || [
  'https://www.truek.xyz',
  'https://truek.xyz'
]

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins allowed_origins
    # ...
  end
end
```

Luego en `.env`:
```bash
CORS_ALLOWED_ORIGINS=https://truek.xyz,https://www.truek.xyz,https://staging.truek.xyz
```

## 📝 Logs

Para ver los requests CORS en los logs:

```bash
# Development
tail -f log/development.log | grep -i cors

# Production
tail -f log/production.log | grep -i cors
```

## ✅ Checklist de Deployment

Antes de deployar a producción:

- [ ] Verificar que los dominios en CORS coincidan con tu frontend
- [ ] Asegurarse de usar HTTPS en producción
- [ ] Probar con cURL los requests OPTIONS y reales
- [ ] Verificar que credentials esté configurado correctamente
- [ ] Reiniciar el servidor después de cambios
- [ ] Probar desde el navegador en el dominio real

## 🎯 Resumen

- ✅ **rack-cors** instalado y configurado
- ✅ Producción: `truek.xyz` y `www.truek.xyz`
- ✅ Development: localhost múltiples puertos
- ✅ Credentials habilitado en producción
- ✅ Cache de preflight 24 horas
- ✅ Todos los métodos HTTP necesarios

¡CORS está listo para producción! 🚀
