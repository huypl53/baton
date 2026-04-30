---
name: nextjs:schema
description: "Build type-safe apps with Drizzle+Zod+TypeScript. Use for: schema-to-type flow, API validation, discriminated unions, type guards, single source of truth patterns."
---

# Type-Safe Schema Flow

Single source of truth from database to UI using Drizzle ORM + Zod + TypeScript.

## Core Principle

```
Drizzle Schema → drizzle-zod → Zod Schema → z.infer<> → TypeScript Type
       ↓              ↓              ↓              ↓
   Database      Validation      Runtime        Compile-time
```

## 1. Drizzle Schema Definition

```typescript
// lib/db/drizzle/schema/products.ts
import { pgTable, text, decimal, bigserial, timestamp, pgEnum } from "drizzle-orm/pg-core";

export const productCategoryEnum = pgEnum("product_category", [
  "t-shirts", "pants", "sweatshirts", "accessories"
]);

export const productsItems = pgTable("products_items", {
  id: bigserial("id", { mode: "number" }).primaryKey(),
  name: text("name").notNull(),
  description: text("description").notNull(),
  price: decimal("price", { precision: 10, scale: 2 }).notNull(),
  category: productCategoryEnum("category").notNull(),
  img: text("img").notNull(),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
});
```

## 2. Zod Schema Generation

```typescript
// Same file or separate schema file
import { createSelectSchema, createInsertSchema } from "drizzle-zod";
import { z } from "zod";

// Base select schema (for reading from DB)
export const selectProductSchema = createSelectSchema(productsItems, {
  // Override decimal → number
  price: z.coerce.number(),
  // Override timestamp → ISO string
  createdAt: z.coerce.string(),
  updatedAt: z.coerce.string(),
});

// Insert schema (for creating records)
export const insertProductSchema = createInsertSchema(productsItems, {
  price: z.coerce.number().positive(),
})
.omit({ id: true, createdAt: true, updatedAt: true });

// Export TypeScript types
export type Product = z.infer<typeof selectProductSchema>;
export type InsertProduct = z.infer<typeof insertProductSchema>;
```

## 3. Schema Composition

```typescript
// lib/db/drizzle/schema/variants.ts
export const selectVariantSchema = createSelectSchema(productsVariants, {
  price: z.coerce.number(),
});

// lib/db/drizzle/schema/products.ts (extended)
export const productWithVariantsSchema = selectProductSchema.extend({
  variants: z.array(selectVariantSchema),
});

export type ProductWithVariants = z.infer<typeof productWithVariantsSchema>;

// Cart item with joined data
export const cartItemWithDetailsSchema = selectCartItemSchema.extend({
  variant: selectVariantSchema,
  product: selectProductSchema,
});

export type CartItemWithDetails = z.infer<typeof cartItemWithDetailsSchema>;
```

## 4. Action-Specific Schemas

```typescript
// Narrow insert schema for specific actions
export const addToCartSchema = insertCartItemSchema
  .omit({ userId: true })  // Server will add userId from session
  .extend({
    quantity: z.number().int().positive().max(99),
  });

export const updateCartItemSchema = z.object({
  id: z.number().int().positive(),
  quantity: z.number().int().positive().max(99),
});

// Pick specific fields
export const createOrderInputSchema = insertOrderItemSchema
  .pick({ userId: true, deliveryDate: true });
```

## 5. Enum Type Safety

```typescript
// Drizzle enum + Zod enum (dual definition for different contexts)
export const sizesEnum = pgEnum("sizes", ["XS", "S", "M", "L", "XL", "XXL"]);
export const ProductSizeZod = z.enum(["XS", "S", "M", "L", "XL", "XXL"]);
export type ProductSize = z.infer<typeof ProductSizeZod>;

// Or derive from const array
const SIZES = ["XS", "S", "M", "L", "XL", "XXL"] as const;
export const ProductSizeZod = z.enum(SIZES);
export type ProductSize = (typeof SIZES)[number];
```

## 6. API Route Validation

```typescript
// app/api/cart/route.ts
import { addToCartSchema } from "@/lib/db/drizzle/schema/cart";

export async function POST(req: Request) {
  try {
    const body = await req.json();
    
    // Validate with Zod (safeParse for graceful handling)
    const parsed = addToCartSchema.safeParse(body);
    if (!parsed.success) {
      return NextResponse.json(
        { error: "Invalid input", details: parsed.error.flatten() },
        { status: 400 }
      );
    }
    
    // parsed.data is fully typed as AddToCartInput
    const result = await cartService.add(userId, parsed.data);
    return NextResponse.json(result);
    
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { error: "Validation failed", errors: error.flatten().fieldErrors },
        { status: 400 }
      );
    }
    return NextResponse.json({ error: "Internal error" }, { status: 500 });
  }
}
```

## 7. Discriminated Union Actions

```typescript
// Reducer actions with discriminated union
export type CartAction =
  | { type: "ADD_ITEM"; payload: { variant: ProductVariant; product: Product } }
  | { type: "UPDATE_ITEM"; payload: { merchandiseId: string; updateType: "increment" | "decrement" | "delete" } }
  | { type: "CLEAR" };

function cartReducer(state: Cart, action: CartAction): Cart {
  switch (action.type) {
    case "ADD_ITEM":
      // TypeScript knows action.payload has variant and product
      return addItem(state, action.payload.variant, action.payload.product);
    case "UPDATE_ITEM":
      // TypeScript knows action.payload has merchandiseId and updateType
      return updateItem(state, action.payload.merchandiseId, action.payload.updateType);
    case "CLEAR":
      // TypeScript knows no payload
      return { ...state, lines: [] };
  }
}
```

## 8. Generic Typed Fetcher

```typescript
import type { AnySchema, InferType } from "yup";

type FetcherConfig<Schema extends AnySchema | null> = {
  readonly method: "GET" | "POST" | "PUT" | "DELETE";
  readonly schema: Schema;
  readonly body?: object;
};

// Overload 1: null schema → null return
export async function fetcher<Schema extends null>(
  path: string,
  config: FetcherConfig<Schema>
): Promise<null>;

// Overload 2: schema provided → inferred return type
export async function fetcher<Schema extends AnySchema>(
  path: string,
  config: FetcherConfig<Schema>
): Promise<InferType<Schema>>;

// Implementation
export async function fetcher<Schema extends AnySchema | null>(
  path: string,
  { method, body, schema }: FetcherConfig<Schema>
): Promise<InferType<Schema> | null> {
  const response = await fetch(path, {
    method,
    headers: { "Content-Type": "application/json" },
    body: body ? JSON.stringify(body) : undefined,
  });
  
  if (!response.ok) {
    throw new ResponseError(response.statusText, response.status);
  }
  
  if (!schema) return null;
  
  const data = await response.json();
  return schema.cast(data);  // Runtime validation + type coercion
}

// Usage - return type is inferred from schema
const products = await fetcher("/api/products", {
  method: "GET",
  schema: productArraySchema,
});
// products is typed as Product[]
```

## 9. Typed Environment Variables

```typescript
// utils/env.ts
type NameToType = {
  readonly NODE_ENV: "production" | "development" | "test";
  readonly DATABASE_URL: string;
  readonly STRIPE_SECRET_KEY: string;
  readonly STRIPE_WEBHOOK_SECRET: string;
  readonly NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY: string;
};

export function getEnv<K extends keyof NameToType>(name: K): NameToType[K] {
  const value = process.env[name];
  if (value === undefined) {
    throw new Error(`Missing environment variable: ${name}`);
  }
  return value as NameToType[K];
}

// Usage
const env = getEnv("NODE_ENV");  // type: "production" | "development" | "test"
const dbUrl = getEnv("DATABASE_URL");  // type: string
```

## 10. Type Guards

```typescript
// Custom error type guard
export class ApiConflictError extends Error {
  readonly code = "CONFLICT" as const;
}

export function isApiConflictError(error: unknown): error is ApiConflictError {
  return error instanceof Error && "code" in error && error.code === "CONFLICT";
}

// Database error type guard
export function isUniqueViolation(error: unknown): boolean {
  return (
    typeof error === "object" &&
    error !== null &&
    "code" in error &&
    error.code === "23505"
  );
}

// Usage
try {
  await db.insert(users).values(data);
} catch (error) {
  if (isUniqueViolation(error)) {
    return { error: "Email already exists" };
  }
  throw error;
}
```

## 11. Component Props from Schema

```typescript
// types/admin.ts
import type { Product, ProductVariant } from "@/lib/db/drizzle/schema";

// Derive props from schema types
export type BasicInfoData = Pick<Product, "name" | "description" | "price" | "category">;

export type VariantFormData = Pick<ProductVariant, "color" | "stripeId" | "sizes" | "images"> & {
  id?: ProductVariant["id"];  // Optional for new variants
};

// Component uses derived type
interface BasicInfoProps {
  initialData?: BasicInfoData;
  errors?: Record<keyof BasicInfoData, string>;
}
```

## 12. Const Assertions for Unions

```typescript
// Provider IDs as const
export const AI_PROVIDER_IDS = [
  "claude", "gemini", "openai", "copilot"
] as const;

export type AiProviderId = (typeof AI_PROVIDER_IDS)[number];
// type: "claude" | "gemini" | "openai" | "copilot"

// Object.freeze for immutable config
export const TAGS = Object.freeze({
  products: "products",
  collections: "collections",
  cart: "cart",
});
// type: { readonly products: "products"; readonly collections: "collections"; readonly cart: "cart" }
```

## Type Flow Summary

| Layer | Source | Output |
|-------|--------|--------|
| Database | Drizzle `pgTable` | Table definition |
| Validation | `createSelectSchema` | Zod schema |
| Insert Validation | `createInsertSchema` | Zod schema (no id/timestamps) |
| TypeScript Type | `z.infer<schema>` | Static type |
| API Route | `safeParse(body)` | Validated + typed data |
| Component | `Pick<Type, "fields">` | Narrowed props |

## Anti-Patterns

| Pattern | Problem | Solution |
|---------|---------|----------|
| Duplicate type definitions | Drift between DB and types | Single source from Drizzle |
| Manual interface matching schema | Out of sync | `z.infer<>` |
| `any` in reducer actions | No narrowing | Discriminated unions |
| Runtime validation only | No IDE autocomplete | Schema → Type flow |
| Hardcoded env values | Type mismatch | Typed `getEnv<K>()` |
