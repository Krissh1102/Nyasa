import { API_BASE_URL } from "../constants/api";

export async function fetchProducts({ categoryId, search, page = 0, size = 20 } = {}) {
  const params = new URLSearchParams();
  if (categoryId) params.set("categoryId", categoryId);
  if (search) params.set("search", search);
  params.set("page", page);
  params.set("size", size);

  const res = await fetch(`${API_BASE_URL}/products?${params}`);
  if (!res.ok) throw new Error(`Failed to fetch products: ${res.status}`);
  const json = await res.json();
  return json.data;
}

export async function fetchProductById(id) {
  const res = await fetch(`${API_BASE_URL}/products/${id}`);
  if (!res.ok) throw new Error(`Failed to fetch product ${id}: ${res.status}`);
  const json = await res.json();
  return json.data;
}

export async function fetchCategories() {
  const res = await fetch(`${API_BASE_URL}/categories`);
  if (!res.ok) throw new Error(`Failed to fetch categories: ${res.status}`);
  const json = await res.json();
  return json.data; // List<CategoryResponse>
}