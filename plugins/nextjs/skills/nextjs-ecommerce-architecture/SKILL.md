---
name: nextjs:ecommerce
description: "Build Next.js ecommerce apps. Use for: cart/checkout flows, Shopify/Stripe/MedusaJS integrations, 4-layer architecture, Server Actions with optimistic updates, RLS patterns."
---

# Next.js Ecommerce Architecture

Build scalable, secure ecommerce applications using battle-tested patterns from production codebases.

## Architecture Decision Tree

```
What's your commerce backend?
├── Shopify → Section: Shopify Storefront Pattern
├── Stripe + PostgreSQL → Section: 4-Layer Architecture  
├── MedusaJS → Section: Medusa Monorepo Pattern
└── Custom API → Section: Generic REST/GraphQL Pattern
```

## 1. Shopify Storefront Pattern (commerce)

**Stack:** Next.js 15 App Router + Shopify Storefront API + Server Actions

### Key Files Structure
```
lib/
  shopify/
    index.ts          # All data fetching with "use cache"
    types.ts          # Domain types (transform Shopify → clean)
    queries/          # GraphQL read operations
    mutations/        # GraphQL write operations
    fragments/        # Reusable GraphQL fragments
components/
  cart/
    cart-context.tsx  # useOptimistic + cartReducer
    actions.ts        # "use server" mutations
    modal.tsx         # Cart UI (client)
```

### Promise Streaming Pattern
```typescript
// layout.tsx (Server Component)
export default async function RootLayout({ children }) {
  const cart = getCart();  // NOT awaited - returns Promise
  return <CartProvider cartPromise={cart}>{children}</CartProvider>;
}

// cart-context.tsx (Client Component)
export function useCart() {
  const { cartPromise } = useContext(CartContext);
  const initialCart = use(cartPromise);  // React 19 use()
  const [optimisticCart, updateOptimisticCart] = useOptimistic(initialCart, cartReducer);
  return useMemo(() => ({ cart: optimisticCart, addCartItem, updateCartItem }), [optimisticCart]);
}
```

### Cache Pattern
```typescript
export async function getCart() {
  "use cache: private";     // Per-user cache
  cacheTag(TAGS.cart);
  cacheLife("seconds");
  // ... fetch from Shopify
}

export async function getProducts() {
  "use cache";              // Shared/CDN cache
  cacheTag(TAGS.products);
  cacheLife("days");
}
```

## 2. 4-Layer Architecture (ecommerce-template)

**Stack:** Next.js 15 + Drizzle ORM + TanStack Query + better-auth + Stripe

### Layer Structure
```
src/
  app/api/           # API routes (validation + auth)
  components/        # UI layer
  hooks/             # TanStack Query wrappers
    cart/
      queries/       # useCart, useCartDetails
      mutations/     # useCartMutation
      keys.ts        # Query key factory
  services/          # Business logic orchestration
    cart.service.ts
  lib/db/drizzle/
    repositories/    # Database access
      cart.repository.ts
    schema/          # Drizzle tables + Zod schemas
```

### Query Key Factory
```typescript
export const CART_QUERY_KEYS = {
  cartList:    (userId: string) => [userId, "cart"] as const,
  cartDetails: (userId: string) => [userId, "cart", "details"] as const,
};
```

### RLS Transaction Wrapper
```typescript
export async function withRLS<T>(
  userId: string | null,
  operation: (tx: RLSClient) => Promise<T>,
): Promise<T> {
  return db.transaction(async (tx) => {
    await tx.execute(sql`SELECT set_config('app.current_user_id', ${userId}, true)`);
    return operation(tx);
  });
}
```

## 3. Medusa Monorepo Pattern (dtc-starter)

**Stack:** Next.js 15 + MedusaJS v2 + Turborepo + Stripe/PayPal

### Structure
```
apps/
  storefront/        # Next.js App Router
    src/
      lib/data/      # "use server" actions
      modules/       # Domain-driven UI slices
        cart/
          components/
          templates/
  backend/           # MedusaJS v2
    src/modules/     # Custom Medusa modules
```

### Cookie + Cache Pattern
```typescript
// Per-user cache namespace
export const getCacheTag = async (tag: string) => {
  const cacheId = cookies.get("_medusa_cache_id")?.value;
  return `${tag}-${cacheId}`;  // e.g. "carts-abc123"
};

// After mutation
const cacheTag = await getCacheTag("carts");
revalidateTag(cacheTag);
```

### URL State Machine for Checkout
```typescript
// Checkout step via URL params
const isOpen = searchParams.get("step") === "address";
router.push(pathname + "?" + createQueryString("step", "review"));
```

## 4. Cart Flow Implementation

### Optimistic Cart Reducer
```typescript
type CartAction =
  | { type: "ADD_ITEM"; payload: { variant: ProductVariant; product: Product } }
  | { type: "UPDATE_ITEM"; payload: { merchandiseId: string; updateType: UpdateType } };

function cartReducer(state: Cart, action: CartAction): Cart {
  switch (action.type) {
    case "ADD_ITEM": {
      const existing = state.lines.find(l => l.merchandise.id === action.payload.variant.id);
      if (existing) {
        return { ...state, lines: state.lines.map(l => 
          l.id === existing.id ? { ...l, quantity: l.quantity + 1 } : l
        )};
      }
      return { ...state, lines: [...state.lines, createCartItem(action.payload)] };
    }
    case "UPDATE_ITEM": {
      // ... quantity update or delete
    }
  }
}
```

### Full Optimistic Update (TanStack)
```typescript
onMutate: async (params) => {
  await queryClient.cancelQueries({ queryKey: CART_QUERY_KEYS.cartList(userId) });
  const previousData = queryClient.getQueryData(CART_QUERY_KEYS.cartList(userId));
  
  // Temp item with negative ID
  const tempItem = { id: -Math.floor(Math.random() * 1e9), ...params };
  queryClient.setQueryData(CART_QUERY_KEYS.cartList(userId), (old) => ({
    items: [tempItem, ...old.items]
  }));
  
  return { previousData, tempItem };
},
onError: (_, __, context) => {
  queryClient.setQueryData(CART_QUERY_KEYS.cartList(userId), context.previousData);
  toast.error("Failed to update cart");
},
onSuccess: () => {
  queryClient.invalidateQueries({ queryKey: CART_QUERY_KEYS.cartDetails(userId) });
}
```

## 5. Checkout Integration

### Stripe Checkout Session
```typescript
// API route
export async function POST(req: Request) {
  const { cartItemIds } = await req.json();
  const items = await cartRepository.findByIds(cartItemIds);
  
  const session = await stripe.checkout.sessions.create({
    mode: "payment",
    line_items: items.map(item => ({
      price: item.stripeId,
      quantity: item.quantity,
    })),
    metadata: { userId, cartItemIds: JSON.stringify(cartItemIds) },
    success_url: `${origin}/result?session_id={CHECKOUT_SESSION_ID}`,
    cancel_url: `${origin}/cart`,
  });
  
  return NextResponse.json({ url: session.url });
}
```

### Webhook Handler (Idempotent)
```typescript
export async function POST(req: Request) {
  const event = stripe.webhooks.constructEvent(body, sig, webhookSecret);
  
  if (event.type === "checkout.session.completed") {
    const session = event.data.object;
    
    // Idempotency check
    const existing = await ordersRepository.findByStripeSessionId(session.id);
    if (existing) return NextResponse.json({ received: true });
    
    // Advisory lock for order number
    await db.execute(sql`SELECT pg_advisory_xact_lock(${LOCK_NS}, ${LOCK_RES})`);
    
    await ordersRepository.createComplete({ ... });
    await cartRepository.clearByUserId(session.metadata.userId);
  }
  
  return NextResponse.json({ received: true });
}
```

## 6. Security Checklist

- [ ] All user-scoped queries use RLS or explicit userId filtering
- [ ] API routes validate session before mutations
- [ ] Stripe webhook verifies signature
- [ ] Cart cookies are HttpOnly + Secure
- [ ] Admin routes check role, not just email comparison
- [ ] No `dangerouslySetInnerHTML` with user content
- [ ] Input validation with Zod on all API routes
- [ ] Rate limiting on checkout endpoints

## Anti-Patterns to Avoid

| Pattern | Problem | Solution |
|---------|---------|----------|
| `new PrismaClient()` per request | Connection exhaustion | Singleton module |
| Cart state in localStorage only | Lost on logout | Server-side + cookie ID |
| No order persistence | Lost purchase records | Create Order on webhook |
| Admin auth via email match | Anyone can be admin | Role field + 2FA |
| `ignoreBuildErrors: true` | Type errors in prod | Fix types, remove flag |
| Hardcoded secrets | Forgeable tokens | Error if env missing |

## References

- `references/shopify-integration.md` - Shopify Storefront API patterns
- `references/stripe-checkout.md` - Stripe integration guide
- `references/drizzle-rls.md` - Row-Level Security setup
