const CART_STORAGE_KEY = 'edition-bildungsmedien-cart';

function readCart() {
  try {
    const stored = JSON.parse(localStorage.getItem(CART_STORAGE_KEY) || '[]');
    return Array.isArray(stored) ? stored : [];
  } catch (error) {
    console.warn('Warenkorb konnte nicht gelesen werden.', error);
    return [];
  }
}

function saveCart(cart) {
  localStorage.setItem(CART_STORAGE_KEY, JSON.stringify(cart));
  updateCartCount();
}

function addToCart(product, format) {
  const cart = readCart();
  const existing = cart.find(item => item.productId === product.id && item.format === format.name);
  if (existing) existing.quantity += 1;
  else cart.push({ productId: product.id, title: product.title, format: format.name, price: format.price, quantity: 1 });
  saveCart(cart);
}

function removeFromCart(index) {
  const cart = readCart();
  cart.splice(index, 1);
  saveCart(cart);
  renderCart();
}

function updateQuantity(index, quantity) {
  const cart = readCart();
  const value = Math.max(1, Number.parseInt(quantity, 10) || 1);
  if (cart[index]) cart[index].quantity = value;
  saveCart(cart);
  renderCart();
}

function clearCart() {
  saveCart([]);
  renderCart();
}

function getCartTotal(cart = readCart()) {
  return cart.reduce((total, item) => total + item.price * item.quantity, 0);
}

function formatCurrency(value) {
  return new Intl.NumberFormat('de-DE', { style: 'currency', currency: 'EUR' }).format(value);
}

function updateCartCount() {
  const count = readCart().reduce((total, item) => total + item.quantity, 0);
  document.querySelectorAll('.cart-count').forEach(element => { element.textContent = count; });
}

function renderCart() {
  const target = document.querySelector('[data-cart-items]');
  if (!target) return;
  const cart = readCart();
  const empty = document.querySelector('[data-cart-empty]');
  const summary = document.querySelector('[data-cart-summary]');
  target.innerHTML = '';
  if (!cart.length) {
    empty.hidden = false;
    summary.hidden = true;
    return;
  }
  empty.hidden = true;
  summary.hidden = false;
  cart.forEach((item, index) => {
    const row = document.createElement('article');
    row.className = 'cart-item';
    row.innerHTML = `<div><h2>${escapeHtml(item.title)}</h2><p>${escapeHtml(item.format)} · ${formatCurrency(item.price)}</p></div><label>Menge <input type="number" min="1" value="${item.quantity}" data-quantity="${index}"></label><strong>${formatCurrency(item.price * item.quantity)}</strong><button class="link-button" type="button" data-remove="${index}">Entfernen</button>`;
    target.appendChild(row);
  });
  document.querySelector('[data-cart-total]').textContent = formatCurrency(getCartTotal(cart));
  target.querySelectorAll('[data-remove]').forEach(button => button.addEventListener('click', () => removeFromCart(Number(button.dataset.remove))));
  target.querySelectorAll('[data-quantity]').forEach(input => input.addEventListener('change', () => updateQuantity(Number(input.dataset.quantity), input.value)));
}

function escapeHtml(value) {
  return String(value).replace(/[&<>"']/g, character => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#039;' }[character]));
}

document.addEventListener('DOMContentLoaded', () => {
  updateCartCount();
  renderCart();
  document.querySelector('[data-clear-cart]')?.addEventListener('click', clearCart);
});
