/* ── NAV: sombra al hacer scroll ─────────────────────────── */
window.addEventListener('scroll', () => {
  document.getElementById('navbar').classList.toggle('scrolled', window.scrollY > 20);
});

/* ── REVEAL ON SCROLL ────────────────────────────────────── */
const observer = new IntersectionObserver((entries) => {
  entries.forEach(e => {
    if (e.isIntersecting) {
      e.target.classList.add('visible');
      observer.unobserve(e.target);
    }
  });
}, { threshold: 0.1 });

document.querySelectorAll('.reveal').forEach((el, i) => {
  el.style.transitionDelay = (i % 4) * 80 + 'ms';
  observer.observe(el);
});

/* ── FAQ ACCORDION ───────────────────────────────────────── */
function toggleFaq(el) {
  const item = el.closest('.faq-item');
  const isOpen = item.classList.contains('open');
  document.querySelectorAll('.faq-item.open').forEach(i => i.classList.remove('open'));
  if (!isOpen) item.classList.add('open');
}

/* ── WAITLIST FORM ───────────────────────────────────────── */
function handleWaitlist(e) {
  e.preventDefault();
  document.getElementById('wl-form').style.display = 'none';
  document.getElementById('wl-success').classList.add('show');

  // Conecta aquí con tu proveedor preferido:
  // -- Opción A: Brevo / Mailchimp / Resend (recomendado, sin backend propio)
  // -- Opción B: Google Sheets vía Make o Zapier
  // -- Opción C: Tu propio endpoint
  //
  // Ejemplo con fetch a tu API:
  // const data = new FormData(e.target);
  // fetch('/api/waitlist', { method: 'POST', body: data })
  //   .then(res => res.json())
  //   .then(data => console.log('OK', data))
  //   .catch(err => console.error('Error', err));
}

/* ── COOKIE BANNER ───────────────────────────────────────── */
function closeCookie() {
  const banner = document.getElementById('cookie');
  banner.style.transition = 'all .3s';
  banner.style.opacity = '0';
  banner.style.transform = 'translateY(80px)';
  setTimeout(() => banner.remove(), 320);
}

/* ── SMOOTH SCROLL ───────────────────────────────────────── */
document.querySelectorAll('a[href^="#"]').forEach(a => {
  a.addEventListener('click', e => {
    const target = document.querySelector(a.getAttribute('href'));
    if (target) {
      e.preventDefault();
      target.scrollIntoView({ behavior: 'smooth' });
    }
  });
});

/* ── HAMBURGER MENU (móvil) ──────────────────────────────── */
document.getElementById('hamburger').addEventListener('click', () => {
  const links = document.querySelector('.nav-links');
  const isOpen = links.style.display === 'flex';
  Object.assign(links.style, {
    display:      isOpen ? '' : 'flex',
    flexDirection:'column',
    position:     'absolute',
    top:          '68px',
    left:         '0',
    right:        '0',
    background:   'var(--cream)',
    padding:      '1.2rem 2rem',
    borderBottom: '1px solid rgba(96,108,56,.1)',
    zIndex:       '99'
  });
});