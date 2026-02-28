# SignoFy — Landing Page

Web de presentación y lista de espera para **SignoFy**, una aplicación gratuita y gamificada para aprender Lengua de Signos Española (LSE).

---

## Descripción

Este repositorio contiene la landing page informativa de SignoFy. La aplicación está en desarrollo activo y aún no tiene descargas disponibles. El objetivo de esta web es explicar la propuesta de valor, mostrar el roadmap real del proyecto y recoger personas interesadas en participar en la beta privada.

La web está construida con **HTML, CSS y JavaScript puro**, sin frameworks ni dependencias externas, para que sea fácil de mantener y desplegar en cualquier hosting estático.

---

## Estructura de archivos

```
signofy/
├── index.html      # Estructura HTML de todas las secciones
├── styles.css      # Estilos, variables CSS y diseño responsive
├── main.js         # Lógica: scroll, FAQ, formulario, menú móvil
└── README.md       # Este archivo
```

---

## Secciones de la web

| Sección | Descripción |
|---|---|
| Nav | Menú fijo con scroll suave y versión colapsable en móvil |
| Hero | Titular principal, nota de honestidad y mockup animado de la app |
| Transparencia | Banner que explica el estado real del proyecto |
| La idea | Por qué existe SignoFy y sus tres pilares principales |
| Funciones | Tarjetas con estado real: en desarrollo / próximamente / en los planes |
| Roadmap | Hoja de ruta sin fechas inventadas |
| Cómo funciona | Los cuatro pasos del método de aprendizaje |
| Lista de espera | Propuesta de valor para apuntarse y garantías de privacidad |
| Formulario | Recogida de nombre, email, motivo y sugerencias |
| FAQ | Seis preguntas frecuentes con acordeón interactivo |
| Footer | Navegación secundaria, contacto y avisos legales |
| Banner de cookies | Aviso mínimo con opción de aceptar o rechazar |

---

## Diseño

### Paleta de colores

| Variable | Valor | Uso principal |
|---|---|---|
| `--cream` | `#FFFBF0` | Fondo general |
| `--forest` | `#1A0A2E` | Texto principal, fondos oscuros |
| `--moss` | `#6B21A8` | Morado vibrante, acentos primarios |
| `--sand` | `#FACC15` | Amarillo limón, highlights |
| `--terra` | `#F97316` | Naranja, CTAs, énfasis |

### Tipografía

- **Títulos y cuerpo:** [Nunito](https://fonts.google.com/specimen/Nunito) — pesos 400, 600, 700, 800 y 900

Ambas fuentes se cargan desde Google Fonts. No requieren instalación local.

---

## Uso en local

No se necesita ningún proceso de build, servidor de desarrollo ni gestor de paquetes. Basta con clonar el repositorio y abrir el archivo principal en el navegador.

```bash
# Abrir directamente en el navegador
open index.html

# O levantar un servidor local simple con Python
python3 -m http.server 3000
# Disponible en http://localhost:3000
```

---

## Formulario de lista de espera

El formulario llama a la función `handleWaitlist()` definida en `main.js`. En su estado actual muestra un mensaje de confirmación visual pero **no envía datos a ningún servidor**. Para activarlo, sustituye el cuerpo de la función con la llamada a tu servicio preferido:

```js
function handleWaitlist(e) {
  e.preventDefault();

  const data = new FormData(e.target);

  fetch('/api/waitlist', {
    method: 'POST',
    body: data
  })
    .then(res => res.json())
    .then(() => {
      document.getElementById('wl-form').style.display = 'none';
      document.getElementById('wl-success').classList.add('show');
    })
    .catch(err => console.error('Error al enviar:', err));
}
```

### Opciones de integración recomendadas

| Servicio | Método | Notas |
|---|---|---|
| [Brevo](https://brevo.com) | API REST o formulario embebido | Plan gratuito amplio, cumple RGPD |
| [Mailchimp](https://mailchimp.com) | Formulario embebido o API | Gratuito hasta 500 contactos |
| [Airtable](https://airtable.com) + Make | Webhook desde el formulario | Sin necesidad de backend propio |
| Google Sheets + Apps Script | `doPost()` en el script del sheet | Gratuito, datos en Google Drive |

---

## Despliegue

Al ser HTML estático, puede desplegarse de forma gratuita en cualquiera de las siguientes plataformas:

| Plataforma | Método |
|---|---|
| [Netlify](https://netlify.com) | Arrastrar la carpeta en netlify.com/drop o conectar el repositorio |
| [Vercel](https://vercel.com) | `vercel deploy` desde la raíz del proyecto |
| [GitHub Pages](https://pages.github.com) | Activar Pages en Settings del repositorio |
| [Cloudflare Pages](https://pages.cloudflare.com) | Conectar el repositorio desde el panel |

---

## Personalización

| Elemento | Ubicación |
|---|---|
| Nombre del proyecto y email de contacto | `index.html` — buscar `SignoFy` y `hola@signofy.app` |
| Colores | `styles.css` — bloque `:root` al inicio del archivo |
| Estado de cada función | `index.html` — sección `#features`, clases `status-current`, `status-soon`, `status-plan` |
| Entradas del roadmap | `index.html` — sección `#roadmap` |
| Preguntas del FAQ | `index.html` — sección `#faq` |
| Año en el pie de página | `index.html` — último `<p>` dentro de `<footer>` |

---

## Accesibilidad

- Estructura semántica con `<nav>`, `<section>`, `<footer>`, `<form>` y `<label>`
- Atributos `required` y `type` correctos en todos los campos del formulario
- Navegación funcional por teclado
- Contraste de color revisado para el texto principal
- Pendiente: añadir la media query `prefers-reduced-motion` para las animaciones de entrada

---

## Estado del proyecto

SignoFy está en desarrollo activo. Esta landing refleja el estado real: no hay descargas disponibles ni usuarios registrados todavía.

- [x] Diseño e identidad visual
- [x] Landing page con lista de espera
- [ ] Desarrollo del núcleo de la aplicación (en curso)
- [ ] Beta privada con las personas apuntadas a la lista
- [ ] Lanzamiento público en App Store y Google Play
- [ ] Diccionario completo, reconocimiento por IA y funciones de comunidad

---

## Licencia

Proyecto de uso personal. Para colaboraciones o reutilización del código, contactar en [hola@signofy.app](mailto:hola@signofy.app).