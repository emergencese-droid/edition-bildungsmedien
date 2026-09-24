function normaliseProduct(product) {
  if (!product || typeof product.id !== 'string' || typeof product.title !== 'string' || typeof product.author !== 'string' || !Array.isArray(product.categories) || !Array.isArray(product.formats) || !product.formats.length) return null;
  const formats = product.formats.filter(format => format && typeof format.name === 'string' && Number.isFinite(Number(format.price))).map(format => ({ ...format, price: Number(format.price) }));
  return formats.length ? { ...product, formats, available: product.available !== false, categories: product.categories.filter(Boolean) } : null;
}

async function loadProducts() {
  const response = await fetch('../data/products.json', { cache: 'no-store' });
  if (!response.ok) throw new Error('Produktdaten konnten nicht geladen werden.');
  const data = await response.json();
  if (!data || !Array.isArray(data.products)) throw new Error('Die Produktdaten haben ein ungültiges Format.');
  const products = data.products.map(normaliseProduct).filter(Boolean);
  if (!products.length) throw new Error('Derzeit sind keine gültigen Produkte verfügbar.');
  return products;
}

function safeText(value) { return escapeHtml(value ?? ''); }
function productCard(product) {
  const lowest = Math.min(...product.formats.map(format => format.price));
  const categories = product.categories.map(category => `<span class="tag">${safeText(category)}</span>`).join('');
  const formats = product.formats.map(format => safeText(format.name)).join(' · ');
  const featured = product.featured ? '<span class="featured-badge">Empfehlung</span>' : '';
  const availability = product.available ? 'Verfügbar' : 'In Vorbereitung';
  return `<article class="product-card">${featured}<div class="product-card-cover">${safeText(product.title)}</div><div class="tag-list">${categories}</div><h2>${safeText(product.title)}</h2><p>${safeText(product.shortDescription)}</p><p class="format-summary">Formate: ${formats}</p><p class="availability ${product.available ? '' : 'is-unavailable'}">${availability}</p><p class="price">ab ${formatCurrency(lowest)}</p><div class="card-actions"><a class="button button-secondary" href="${safeText(product.productUrl)}">Details</a><button class="button button-primary quick-add" type="button" data-product="${safeText(product.id)}" ${product.available ? '' : 'disabled'}>${product.available ? 'Hinzufügen' : 'Nicht verfügbar'}</button></div></article>`;
}

function renderFormatOptions(product, container) { container.innerHTML = product.formats.map((format, index) => `<label class="format-option"><input type="radio" name="format" value="${safeText(format.name)}" ${index === 0 ? 'checked' : ''}><span>${safeText(format.name)}<strong>${formatCurrency(format.price)}</strong></span></label>`).join(''); }

function escapeHtml(value) { return String(value).replace(/[&<>"']/g, character => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#039;' }[character])); }

document.addEventListener('DOMContentLoaded', async () => {
  const list = document.querySelector('#product-list');
  const detail = document.querySelector('[data-product-id]');
  try {
    const products = await loadProducts();
    if (list) {
      const category = document.querySelector('#category-filter');
      const sort = document.querySelector('#sort-products');
      const search = document.querySelector('#product-search');
      [...new Set(products.flatMap(product => product.categories))].sort((a, b) => a.localeCompare(b, 'de')).forEach(item => category?.insertAdjacentHTML('beforeend', `<option value="${safeText(item)}">${safeText(item)}</option>`));
      const render = () => {
        const query = (search?.value || '').trim().toLocaleLowerCase('de');
        let visible = products.filter(product => (!category || category.value === 'all' || product.categories.includes(category.value)) && (!query || [product.title, product.author, ...product.categories].join(' ').toLocaleLowerCase('de').includes(query)));
        visible = [...visible].sort((a, b) => sort?.value === 'title' ? a.title.localeCompare(b.title, 'de') : sort?.value === 'price-desc' ? b.formats[0].price - a.formats[0].price : a.formats[0].price - b.formats[0].price);
        list.innerHTML = visible.length ? visible.map(productCard).join('') : '<p class="empty-state">Keine passenden Produkte gefunden.</p>';
        list.querySelectorAll('.quick-add').forEach(button => button.addEventListener('click', () => { const product = products.find(item => item.id === button.dataset.product); addToCart(product, product.formats[0]); button.textContent = 'Hinzugefügt'; button.disabled = true; }));
      };
      category?.addEventListener('change', render); sort?.addEventListener('change', render); search?.addEventListener('input', render); render();
    }
    if (detail) {
      const product = products.find(item => item.id === detail.dataset.productId);
      if (!product) throw new Error('Produkt nicht gefunden.');
      const options = detail.querySelector('[data-format-options]');
      renderFormatOptions(product, options);
      detail.querySelector('.add-to-cart')?.addEventListener('click', event => { const selected = detail.querySelector('input[name="format"]:checked'); const format = product.formats.find(item => item.name === selected?.value); if (addToCart(product, format)) event.target.textContent = 'Zum Warenkorb hinzugefügt'; });
    }
  } catch (error) {
    const message = `<p class="error-message" role="alert">${safeText(error.message)} Bitte versuchen Sie es später erneut.</p>`;
    if (list) list.innerHTML = message;
    if (detail) detail.querySelector('[data-format-options]').innerHTML = message;
  }
});
