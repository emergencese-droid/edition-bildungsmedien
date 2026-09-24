const CART_STORAGE_KEY = 'edition-bildungsmedien-cart';

function readCart() {
  try {
    const raw = localStorage.getItem(CART_STORAGE_KEY);
    if (!raw) return [];
    const parsed = JSON.parse(raw);
    if (!Array.isArray(parsed)) throw new Error('Ungültiges Warenkorbformat.');
    return parsed.filter(item => item && typeof item.productId === 'string' && typeof item.format === 'string' && Number.isFinite(Number(item.price)) && Number.isInteger(Number(item.quantity)) && Number(item.quantity) > 0);
  } catch (error) {
    console.warn('Warenkorb wurde zurückgesetzt:', error);
    try { localStorage.removeItem(CART_STORAGE_KEY); } catch (_) { /* Storage kann blockiert sein. */ }
    return [];
  }
}

function saveCart(cart) {
  try { localStorage.setItem(CART_STORAGE_KEY, JSON.stringify(cart)); }
  catch (error) { console.warn('Warenkorb konnte nicht gespeichert werden:', error); }
  updateCartCount();
}

function addToCart(product, format) {
  if (!product || !format || !product.available) return false;
  const cart = readCart();
  const existing = cart.find(item => item.productId === product.id && item.format === format.name);
  if (existing) existing.quantity += 1;
  else cart.push({ productId: product.id, title: product.title, format: format.name, price: Number(format.price), quantity: 1 });
  saveCart(cart);
  return true;
}

function removeFromCart(index) { const cart = readCart(); cart.splice(index, 1); saveCart(cart); renderCart(); }
function updateQuantity(index, quantity) { const cart = readCart(); if (cart[index]) cart[index].quantity = Math.max(1, Number.parseInt(quantity, 10) || 1); saveCart(cart); renderCart(); }
function clearCart() { saveCart([]); renderCart(); }
function getCartTotal(cart = readCart()) { return cart.reduce((total, item) => total + Number(item.price) * Number(item.quantity), 0); }
function formatCurrency(value) { return new Intl.NumberFormat('de-DE', { style: 'currency', currency: 'EUR' }).format(Number(value) || 0); }
function updateCartCount() { const count = readCart().reduce((total, item) => total + item.quantity, 0); document.querySelectorAll('.cart-count').forEach(element => { element.textContent = count; }); }
function escapeHtml(value) { return String(value).replace(/[&<>"']/g, character => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#039;' }[character])); }

function renderCart() {
  const target = document.querySelector('[data-cart-items]');
  if (!target) return;
  const cart = readCart();
  const empty = document.querySelector('[data-cart-empty]');
  const summary = document.querySelector('[data-cart-summary]');
  target.replaceChildren();
  if (!cart.length) { if (empty) empty.hidden = false; if (summary) summary.hidden = true; return; }
  if (empty) empty.hidden = true;
  if (summary) summary.hidden = false;
  cart.forEach((item, index) => {
    const row = document.createElement('article');
    row.className = 'cart-item';
    row.innerHTML = `<div><h2>${escapeHtml(item.title)}</h2><p>${escapeHtml(item.format)} · ${formatCurrency(item.price)}</p></div><label>Menge <input type="number" min="1" value="${item.quantity}" data-quantity="${index}" aria-label="Menge von ${escapeHtml(item.title)}"></label><strong>${formatCurrency(item.price * item.quantity)}</strong><button class="link-button" type="button" data-remove="${index}">Entfernen</button>`;
    target.appendChild(row);
  });
  const total = document.querySelector('[data-cart-total]');
  if (total) total.textContent = formatCurrency(getCartTotal(cart));
  target.querySelectorAll('[data-remove]').forEach(button => button.addEventListener('click', () => removeFromCart(Number(button.dataset.remove))));
  target.querySelectorAll('[data-quantity]').forEach(input => input.addEventListener('change', () => updateQuantity(Number(input.dataset.quantity), input.value)));
}

document.addEventListener('DOMContentLoaded', () => { updateCartCount(); renderCart(); document.querySelector('[data-clear-cart]')?.addEventListener('click', clearCart); });
