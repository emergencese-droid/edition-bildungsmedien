document.addEventListener('DOMContentLoaded', () => {
  const itemsTarget = document.querySelector('[data-checkout-items]');
  const totalTarget = document.querySelector('[data-checkout-total]');
  const form = document.querySelector('#checkout-form');
  if (!form || !itemsTarget || !totalTarget) return;
  const cart = readCart();
  if (!cart.length) {
    itemsTarget.innerHTML = '<p>Der Warenkorb ist leer.</p>';
    form.querySelector('button[type="submit"]').disabled = true;
    return;
  }
  itemsTarget.innerHTML = cart.map(item => `<p>${escapeHtml(item.title)} · ${escapeHtml(item.format)} × ${item.quantity}<br><strong>${formatCurrency(item.price * item.quantity)}</strong></p>`).join('');
  totalTarget.textContent = formatCurrency(getCartTotal(cart));
  form.addEventListener('submit', event => {
    event.preventDefault();
    const error = document.querySelector('#checkout-error');
    if (!form.checkValidity()) {
      error.textContent = 'Bitte füllen Sie alle Pflichtfelder korrekt aus.';
      error.hidden = false;
      form.reportValidity();
      return;
    }
    const payload = { customer: Object.fromEntries(new FormData(form)), items: cart, total: getCartTotal(cart) };
    console.info('Checkout-Demo-Payload:', payload);
    window.location.href = 'success.html';
  });
});
