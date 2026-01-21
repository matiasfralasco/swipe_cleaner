# 🤝 Guía de Contribuciones

¡Gracias por interesarte en contribuir a Swipe Cleaner! Aquí están las directrices.

## Cómo Contribuir

### 1. Fork y Clona

```bash
git clone https://github.com/tu-usuario/swipe_cleaner.git
cd swipe_cleaner
```

### 2. Crea una rama

```bash
git checkout -b feature/tu-caracteristica
# o para bugs
git checkout -b fix/tu-bug
```

### 3. Haz cambios y commit

```bash
git add .
git commit -m "feat: descripción clara de cambios"
```

**Usa commits claros:**
- `feat:` para nuevas características
- `fix:` para correcciones
- `refactor:` para refactorización
- `docs:` para documentación
- `style:` para formato/estilos

### 4. Push y Pull Request

```bash
git push origin feature/tu-caracteristica
```

Ve a GitHub y abre un Pull Request describiendo:
- Qué cambios hiciste
- Por qué
- Cómo testearlo

## Estándares de Código

- Usa Dart Analyzer: `dart analyze`
- Formatea con: `dart format lib/ test/`
- Sigue [Effective Dart](https://dart.dev/guides/language/effective-dart)

## Reportar Bugs

Abre un [Issue](https://github.com/matiasfralasco/swipe_cleaner/issues) con:

- Descripción clara del problema
- Pasos para reproducir
- Comportamiento esperado vs actual
- Versión de Flutter y dispositivo

## Preguntas

Si tienes dudas, abre una [Discussion](https://github.com/matiasfralasco/swipe_cleaner/discussions).

---

¡Agradecemos tu ayuda! 🙌
