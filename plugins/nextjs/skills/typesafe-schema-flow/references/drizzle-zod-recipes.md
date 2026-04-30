# Drizzle + Zod Recipes

## Schema Definition Patterns

### Basic Table + Schema
```typescript
import { pgTable, text, integer, timestamp, bigserial } from "drizzle-orm/pg-core";
import { createSelectSchema, createInsertSchema } from "drizzle-zod";
import { z } from "zod";

export const users = pgTable("users", {
  id: bigserial("id", { mode: "number" }).primaryKey(),
  email: text("email").notNull().unique(),
  name: text("name").notNull(),
  age: integer("age"),
  createdAt: timestamp("created_at").defaultNow().notNull(),
});

export const selectUserSchema = createSelectSchema(users);
export const insertUserSchema = createInsertSchema(users)
  .omit({ id: true, createdAt: true });

export type User = z.infer<typeof selectUserSchema>;
export type InsertUser = z.infer<typeof insertUserSchema>;
```

### Enum Handling
```typescript
// Drizzle enum
export const statusEnum = pgEnum("status", ["pending", "active", "archived"]);

// In table
export const posts = pgTable("posts", {
  status: statusEnum("status").default("pending").notNull(),
});

// Zod enum (for validation outside DB)
export const StatusZod = z.enum(["pending", "active", "archived"]);
export type Status = z.infer<typeof StatusZod>;
```

### Array Columns
```typescript
export const productsVariants = pgTable("products_variants", {
  sizes: text("sizes").array().notNull(),
  images: text("images").array().notNull(),
});

// Zod override for validation
export const selectVariantSchema = createSelectSchema(productsVariants, {
  sizes: z.array(z.enum(["XS", "S", "M", "L", "XL"])),
  images: z.array(z.string().url()),
});
```

### Decimal Handling
```typescript
// Drizzle stores as string
export const products = pgTable("products", {
  price: decimal("price", { precision: 10, scale: 2 }).notNull(),
});

// Coerce to number in schema
export const selectProductSchema = createSelectSchema(products, {
  price: z.coerce.number().positive(),
});
```

## Schema Composition

### Extend Base Schema
```typescript
export const productWithVariantsSchema = selectProductSchema.extend({
  variants: z.array(selectVariantSchema),
  category: selectCategorySchema.optional(),
});
```

### Pick Fields
```typescript
export const productSummarySchema = selectProductSchema.pick({
  id: true,
  name: true,
  price: true,
});
```

### Omit Fields
```typescript
export const publicUserSchema = selectUserSchema.omit({
  password: true,
  internalNotes: true,
});
```

### Merge Schemas
```typescript
export const fullOrderSchema = selectOrderSchema.merge(
  z.object({
    items: z.array(selectOrderItemSchema),
    customer: selectCustomerSchema,
  })
);
```

## Validation Patterns

### API Input Validation
```typescript
const createProductSchema = insertProductSchema.extend({
  // Add custom validations
  name: z.string().min(3).max(100),
  price: z.number().positive().max(99999.99),
  variants: z.array(insertVariantSchema).min(1),
});

// In API route
const parsed = createProductSchema.safeParse(await req.json());
if (!parsed.success) {
  return NextResponse.json({
    error: "Validation failed",
    details: parsed.error.flatten(),
  }, { status: 400 });
}
```

### Partial Updates
```typescript
export const updateProductSchema = insertProductSchema.partial();
// All fields optional

export const updatePriceSchema = insertProductSchema.pick({ price: true });
// Only price field
```

### Refinements
```typescript
export const orderSchema = z.object({
  items: z.array(orderItemSchema).min(1),
  shippingDate: z.date(),
  deliveryDate: z.date(),
}).refine(
  (data) => data.deliveryDate > data.shippingDate,
  { message: "Delivery must be after shipping", path: ["deliveryDate"] }
);
```

## Type Inference Patterns

### From Schema
```typescript
type User = z.infer<typeof selectUserSchema>;
type InsertUser = z.infer<typeof insertUserSchema>;
type UpdateUser = z.infer<typeof updateUserSchema>;
```

### From Table (Drizzle direct)
```typescript
import { InferSelectModel, InferInsertModel } from "drizzle-orm";

type User = InferSelectModel<typeof users>;
type InsertUser = InferInsertModel<typeof users>;
```

### Derived Component Props
```typescript
type UserFormData = Pick<InsertUser, "email" | "name">;
type UserDisplayProps = Pick<User, "id" | "name" | "createdAt">;
```

## Relations + Schema

```typescript
// Define relations
export const usersRelations = relations(users, ({ many }) => ({
  posts: many(posts),
  orders: many(orders),
}));

// Query with relations
const result = await db.query.users.findFirst({
  where: eq(users.id, userId),
  with: { posts: true, orders: true },
});

// Type for result with relations
export const userWithRelationsSchema = selectUserSchema.extend({
  posts: z.array(selectPostSchema),
  orders: z.array(selectOrderSchema),
});
type UserWithRelations = z.infer<typeof userWithRelationsSchema>;
```
