# 🚀 Deployment Checklist - Truek API

## Pre-Deployment

### ✅ Backend Configuration

- [ ] **Variables de Entorno configuradas**
  ```bash
  GOOGLE_CLIENT_ID=your_client_id.apps.googleusercontent.com
  RAILS_ENV=production
  SECRET_KEY_BASE=generate_with_rails_secret
  DATABASE_URL=postgres://...  # Si usas PostgreSQL
  ```

- [ ] **CORS configurado** para truek.xyz y www.truek.xyz
  - Archivo: `config/initializers/cors.rb`
  - ✅ Ya configurado

- [ ] **Base de datos migrada**
  ```bash
  rails db:migrate RAILS_ENV=production
  ```

- [ ] **Tests pasando**
  ```bash
  bundle exec rspec  # Debe mostrar: 48 examples, 0 failures
  ```

### ✅ Google OAuth Configuration

- [ ] **Google Client ID obtenido**
  - Ve a: https://console.cloud.google.com/
  - Navega a: APIs & Services → Credentials
  - Crea OAuth 2.0 Client ID (si no existe)

- [ ] **URLs autorizadas configuradas en Google Cloud**
  ```
  Authorized JavaScript origins:
    - https://truek.xyz
    - https://www.truek.xyz
  
  Authorized redirect URIs:
    - https://truek.xyz/auth/callback
    - https://www.truek.xyz/auth/callback
  ```

- [ ] **Mismo Client ID en backend y frontend**
  - Backend: Variable `GOOGLE_CLIENT_ID` en `.env`
  - Frontend: Variable `VITE_GOOGLE_CLIENT_ID` (o equivalente)

### ✅ Security Checks

- [ ] **SECRET_KEY_BASE generado**
  ```bash
  rails secret
  # Copia el output y úsalo como SECRET_KEY_BASE
  ```

- [ ] **Archivo .env NO está en Git**
  - Verificar que `.env` esté en `.gitignore`
  - Solo subir `.env.example`

- [ ] **HTTPS habilitado en producción**
  - CORS solo acepta HTTPS en producción
  - Google OAuth requiere HTTPS

- [ ] **CORS restringido a dominios específicos**
  - ✅ Ya configurado para truek.xyz únicamente

## Deployment

### 🎯 Steps

1. **Deploy Backend**
   ```bash
   # Ejemplo con Railway, Heroku, Render, etc.
   git push production main
   
   # O manualmente
   bundle install --without development test
   rails assets:precompile  # Si tienes assets
   rails db:migrate RAILS_ENV=production
   ```

2. **Configurar Variables de Entorno en el Host**
   - `GOOGLE_CLIENT_ID`
   - `SECRET_KEY_BASE`
   - `RAILS_ENV=production`
   - `DATABASE_URL` (si aplica)

3. **Verificar que el servidor esté corriendo**
   ```bash
   curl https://api.truek.xyz/up
   # Debe devolver: 200 OK
   ```

4. **Testar CORS**
   ```bash
   ./scripts/test_cors.sh https://api.truek.xyz https://truek.xyz
   ```

## Post-Deployment

### ✅ Verification Tests

- [ ] **Health Check**
  ```bash
  curl https://api.truek.xyz/up
  # Expected: {"status":"ok"}
  ```

- [ ] **CORS Headers**
  ```bash
  curl -I https://api.truek.xyz/up \
    -H "Origin: https://truek.xyz"
  
  # Should see:
  # Access-Control-Allow-Origin: https://truek.xyz
  # Access-Control-Expose-Headers: Authorization
  ```

- [ ] **Google OAuth Endpoint**
  ```bash
  curl -X POST https://api.truek.xyz/api/v1/auth/google \
    -H "Content-Type: application/json" \
    -H "Origin: https://truek.xyz" \
    -d '{"token":"test"}' \
    -v
  
  # Should see CORS headers in response
  ```

- [ ] **Frontend puede conectar**
  - Abrir DevTools en https://truek.xyz
  - Hacer un request de test desde la consola
  ```javascript
  fetch('https://api.truek.xyz/up')
    .then(r => r.json())
    .then(d => console.log('✅ Backend connected:', d))
  ```

### ✅ Frontend Integration

- [ ] **Frontend configurado**
  - `.env` con `VITE_API_URL` y `VITE_GOOGLE_CLIENT_ID`
  - `@react-oauth/google` instalado
  - `GoogleOAuthProvider` configurado

- [ ] **Test de login con Google**
  - Abrir https://truek.xyz
  - Click en "Sign in with Google"
  - Verificar que se reciba el token JWT
  - Verificar que el token se guarde en localStorage

- [ ] **Test de requests autenticados**
  - Hacer login
  - Intentar GET /api/v1/users/me con el token
  - Verificar que funcione

## Monitoring

### 📊 Logs

```bash
# Ver logs en producción
tail -f log/production.log

# Filtrar CORS issues
tail -f log/production.log | grep -i cors

# Ver errores
tail -f log/production.log | grep ERROR
```

### 🔍 Common Issues

#### CORS Error en Frontend
```
Access to fetch at 'https://api.truek.xyz' from origin 'https://truek.xyz' 
has been blocked by CORS policy
```

**Solution:**
- Verificar que el dominio esté en `config/initializers/cors.rb`
- Verificar que estés usando HTTPS
- Reiniciar el servidor después de cambios

#### Google OAuth Token Invalid
```
{"error": "Invalid Google token"}
```

**Solution:**
- Verificar que `GOOGLE_CLIENT_ID` esté configurado
- Verificar que el Client ID sea el mismo en backend y frontend
- Verificar que el token no haya expirado

#### Unauthorized Error
```
{"error": "Unauthorized"}
```

**Solution:**
- Verificar que el token JWT esté en el header Authorization
- Formato: `Authorization: Bearer eyJhbGciOi...`
- Verificar que el token no haya expirado (24 horas)

## Performance

### ⚡ Optimizations

- [ ] **Database Connection Pooling**
  - Configurar en `config/database.yml`
  - Pool size adecuado para tu carga

- [ ] **Precompile Assets** (si aplica)
  ```bash
  rails assets:precompile RAILS_ENV=production
  ```

- [ ] **Enable Gzip Compression**
  - Configurar en tu web server (nginx, etc.)

- [ ] **SSL/TLS Certificate**
  - Usar Let's Encrypt o tu proveedor
  - Auto-renewal configurado

## Security

### 🔒 Hardening

- [ ] **Rate Limiting** (opcional pero recomendado)
  - Usar `rack-attack` gem
  - Limitar requests por IP

- [ ] **Logging**
  - Configurar log rotation
  - No loggear información sensible

- [ ] **Backup Database**
  - Configurar backups automáticos
  - Testar restore process

## Rollback Plan

Si algo sale mal:

1. **Revertir deploy**
   ```bash
   git revert HEAD
   git push production main
   ```

2. **Revisar logs**
   ```bash
   tail -100 log/production.log
   ```

3. **Verificar base de datos**
   ```bash
   rails db:migrate:status RAILS_ENV=production
   ```

4. **Contactar soporte de hosting** si es necesario

## Success Criteria

✅ Deployment exitoso cuando:

- [ ] Backend responde en https://api.truek.xyz
- [ ] CORS funciona desde truek.xyz
- [ ] Google OAuth funciona
- [ ] Login tradicional funciona
- [ ] Requests autenticados funcionan
- [ ] Tests pasan (48/48)
- [ ] No hay errores en logs
- [ ] Frontend se conecta sin errores

## 🎉 Post-Launch

- [ ] Monitorear logs por 24 horas
- [ ] Verificar performance
- [ ] Recopilar feedback de usuarios
- [ ] Iterar y mejorar

---

**¿Listo para el lanzamiento?** 🚀

Sigue esta checklist paso a paso y tu deployment será exitoso.

**Documentación de referencia:**
- `CORS_CONFIGURATION.md` - CORS details
- `GOOGLE_OAUTH_SETUP.md` - OAuth setup
- `API_AUTHENTICATION.md` - API endpoints
