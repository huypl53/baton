# Architecture Pattern Comparison

Quick reference comparing the 4 major ecommerce architecture patterns.

## At a Glance

| Pattern | Router | State | Database | Auth | Payment |
|---------|--------|-------|----------|------|---------|
| **Shopify Storefront** | App Router | `useOptimistic` | Shopify API | Cookie-only | Shopify hosted |
| **4-Layer (Drizzle)** | App Router | TanStack Query | PostgreSQL + RLS | better-auth | Stripe |
| **Medusa Monorepo** | App Router | Server Cache | MedusaJS (PG) | Medusa JWT | Stripe/PayPal |
| **Legacy (Prisma)** | Pages Router | React Query v3 | PostgreSQL | NextAuth | Stripe |

## State Management Decision

```
Need real-time optimistic updates?
├── Yes, React 19 available → useOptimistic (Shopify pattern)
├── Yes, need rollback → TanStack Query onMutate (4-Layer)
├── No, server-rendered OK → Cookie + revalidateTag (Medusa)
└── Legacy codebase → React Query v3 + useReducer
```

## Data Fetching Decision

```
What's your Next.js version?
├── 15 (canary) → "use cache" + cacheLife + revalidateTag
├── 14 → unstable_cache + revalidateTag
└── 12-13 → getServerSideProps + React Query hydration
```

## When to Use Each

### Shopify Storefront
- ✅ Using Shopify as commerce backend
- ✅ Want fastest time-to-market
- ✅ No custom database needs
- ❌ Need custom order workflows

### 4-Layer (Drizzle)
- ✅ Building custom commerce platform
- ✅ Need Row-Level Security
- ✅ Complex business logic
- ✅ Multi-tenant requirements

### Medusa Monorepo
- ✅ Want Shopify-like features, self-hosted
- ✅ Need multi-region/currency
- ✅ Custom fulfillment workflows
- ❌ Small team (Medusa has learning curve)

### Legacy (Prisma)
- ⚠️ Only for existing codebases
- ⚠️ Migrate to App Router when possible
