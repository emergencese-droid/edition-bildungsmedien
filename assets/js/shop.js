async function loadProducts() {
  const response = await fetch('../data/products.json');
  if (!response.ok) throw new Error('Produktdaten konnten nicht geladen werden.');
  const data = await response.json();
  if (!Array.isArray(data.products)) throw new Error('Produktdaten haben ein ungültiges Format.');
  return data.products;
}

function productCard(product) {
  const lowest = Math.min(...product.formats.map(format => format.price));
  const categories = product.categories.map(category => `<span>${category}</span>`).join('');
  return `<article class="product-card"><div class="product-card-cover">${product.title}</div><p class="card-kicker">${categories}</p><h2>${product.title}</h2><p>${product.shortDescription}</p><p class="price">ab ${formatCurrency(lowest)}</p><div class="card-actions"><a class="button button-secondary" href="${product.productUrl}">Details</a><button class="button button-primary quick-add" type="button" data-product="${product.id}">Auswahl hinzufügen</button></div></article>`;
}

function renderFormatOptions(product, container) {
  container.innerHTML = product.formats.map((format, index) => `<label class="format-option"><input type="radio" name="format" value="${format.name}" data-price="${format.price}" ${index === 0 ? 'checked' : ''}><span>${format.name}<strong>${formatCurrency(format.price)}</strong></span></label>`).join('');
}

document.addEventListener('DOMContentLoaded', async () => {
  const list = document.querySelector('#product-list');
  const detail = document.querySelector('[data-product-id]');
  try {
    const products = await loadProducts();
    if (list) {
      const category = document.querySelector('#category-filter');
      const sort = document.querySelector('#sort-products');
      [...new Set(products.flatMap(product => product.categories))].sort().forEach(item => category.insertAdjacentHTML('beforeend', `<option value="${item}">${item}</option>`));
      const render = () => {
        let visible = products.filter(product => category.value === 'all' || product.categories.includes(category.value));
        visible.sort((a, b) => sort.value === 'title' ? a.title.localeCompare(b.title, 'de') : (sort.value === 'price-asc' ? a.formats[0].price - b.formats[0].price : b.formats[0].price - a.formats[0].price));
        list.innerHTML = visible.length ? visible.map(productCard).join('') : '<p>Keine Produkte gefunden.</p>';
        list.querySelectorAll('.quick-add').forEach(button => button.addEventListener('click', () => { const product = products.find(item => item.id === button.dataset.product); addToCart(product, product.formats[0]); button.textContent = 'Hinzugefügt'; }));
      };
      category.addEventListener('change', render); sort.addEventListener('change', render); render();
    }
    if (detail) {
      const product = products.find(item => item.id === detail.dataset.productId);
      if (!product) throw new Error('Produkt nicht gefunden.');
      renderFormatOptions(product, detail.querySelector('[data-format-options]));
      detail.querySelector('.add-to-cart').addEventListener('click', event => { const selected = detail.querySelector('input[name="format"]:checked'); const format = product.formats.find(item => item.name === selected.value); addToCart(product, format); event.target.textContent = 'Zum Warenkorb hinzugefügt'; });
    }
  } catch (error) {
    if (list) list.innerHTML = `<p class="error-message">${error.message} Bitte versuchen Sie es später erneut.</p>`;
    if (detail) detail.querySelector('[data-format-options]').innerHTML = `<p class="error-message">${error.message}</p>`;
  }
});
