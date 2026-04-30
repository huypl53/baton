---
name: nextjs:optimistic
description: "Implement TanStack Query v5 optimistic updates. Use for: instant UI feedback, rollback on error, dual-cache updates, query key factories, temp-id patterns."
---

# TanStack Query Optimistic Updates

Implement instant, rollback-safe UI updates using TanStack Query v5 patterns.

## Core Concept

```
User action → Optimistic UI update (instant) → API call (background)
                                                    ↓
                              Success → Invalidate related queries
                              Error → Rollback to snapshot
```

## 1. Query Key Factory

Scope keys by user for proper cache isolation.

```typescript
// hooks/cart/keys.ts
export const CART_QUERY_KEYS = {
  all:         (userId: string) => [userId, "cart"] as const,
  list:        (userId: string) => [userId, "cart", "list"] as const,
  details:     (userId: string) => [userId, "cart", "details"] as const,
  item:        (userId: string, itemId: number) => [userId, "cart", "item", itemId] as const,
} as const;

// Hierarchical invalidation:
// invalidateQueries({ queryKey: CART_QUERY_KEYS.all(userId) })
// → invalidates list, details, and all items
```

## 2. Full Optimistic Add Pattern

```typescript
export const useCartMutation = () => {
  const queryClient = useQueryClient();
  const { data: session } = useSession();
  const userId = session?.user?.id;

  const add = useMutation({
    mutationFn: (params: AddToCartParams) => api.cart.add(userId!, params),
    
    onMutate: async (params) => {
      // 1. Guard: abort if not authenticated
      if (!userId) {
        toast.info("Please login to add items");
        throw new Error("Unauthorized");
      }

      // 2. Cancel in-flight queries (prevent race conditions)
      await queryClient.cancelQueries({ 
        queryKey: CART_QUERY_KEYS.list(userId) 
      });

      // 3. Snapshot current state for rollback
      const previousList = queryClient.getQueryData<CartListResponse>(
        CART_QUERY_KEYS.list(userId)
      );
      const previousDetails = queryClient.getQueryData<CartDetailsResponse>(
        CART_QUERY_KEYS.details(userId)
      );

      // 4. Create temp item with negative ID (clearly temporary)
      const tempItem: CartItem = {
        id: -Math.floor(Math.random() * 1e9),
        userId: "temp",
        variantId: params.variantId,
        size: params.size,
        quantity: params.quantity,
        stripeId: params.stripeId,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      };

      // 5. Optimistically update cache (upsert logic)
      queryClient.setQueryData<CartListResponse>(
        CART_QUERY_KEYS.list(userId),
        (old = { items: [] }) => {
          const existingIdx = old.items.findIndex(
            i => i.variantId === params.variantId && i.size === params.size
          );
          
          if (existingIdx >= 0) {
            // Update existing item quantity
            const updated = [...old.items];
            updated[existingIdx] = {
              ...updated[existingIdx],
              quantity: updated[existingIdx].quantity + params.quantity,
              updatedAt: new Date().toISOString(),
            };
            return { items: updated };
          }
          
          // Add new item at beginning
          return { items: [tempItem, ...old.items] };
        }
      );

      // 6. Return context for onError/onSuccess
      return { previousList, previousDetails, tempItem };
    },

    onSuccess: (data, _, context) => {
      const { tempItem } = context!;
      
      // Replace temp item with server-confirmed item
      queryClient.setQueryData<CartListResponse>(
        CART_QUERY_KEYS.list(userId!),
        (old = { items: [] }) => ({
          items: old.items.map(item => 
            item.id === tempItem.id ? data : item
          ),
        })
      );
      
      // Invalidate details (needs fresh server data with joins)
      void queryClient.invalidateQueries({ 
        queryKey: CART_QUERY_KEYS.details(userId!) 
      });
      
      toast.success("Added to cart");
    },

    onError: (error, _, context) => {
      // Full rollback to snapshot
      if (context?.previousList && userId) {
        queryClient.setQueryData(
          CART_QUERY_KEYS.list(userId),
          context.previousList
        );
      }
      if (context?.previousDetails && userId) {
        queryClient.setQueryData(
          CART_QUERY_KEYS.details(userId),
          context.previousDetails
        );
      }
      
      toast.error(`Failed: ${error.message}`);
    },
  });

  return { add: add.mutate, isAdding: add.isPending, addError: add.error };
};
```

## 3. Dual-Cache Update (List + Details)

When you have both a list cache and a detailed/joined cache:

```typescript
onMutate: async (params) => {
  // Cancel BOTH queries
  await Promise.all([
    queryClient.cancelQueries({ queryKey: CART_QUERY_KEYS.list(userId) }),
    queryClient.cancelQueries({ queryKey: CART_QUERY_KEYS.details(userId) }),
  ]);

  // Snapshot BOTH
  const previousList = queryClient.getQueryData(CART_QUERY_KEYS.list(userId));
  const previousDetails = queryClient.getQueryData(CART_QUERY_KEYS.details(userId));

  // Update BOTH caches
  queryClient.setQueryData(CART_QUERY_KEYS.list(userId), (old) => {
    // ... update list
  });
  
  queryClient.setQueryData(CART_QUERY_KEYS.details(userId), (old) => {
    // ... update details (may need to construct full object)
  });

  return { previousList, previousDetails };
},

onError: (_, __, context) => {
  // Rollback BOTH
  queryClient.setQueryData(CART_QUERY_KEYS.list(userId), context.previousList);
  queryClient.setQueryData(CART_QUERY_KEYS.details(userId), context.previousDetails);
},
```

## 4. Update Quantity Pattern

```typescript
const update = useMutation({
  mutationFn: ({ id, quantity }: UpdateParams) => 
    api.cart.update(userId!, id, quantity),
  
  onMutate: async ({ id, quantity }) => {
    await queryClient.cancelQueries({ queryKey: CART_QUERY_KEYS.list(userId!) });
    const previous = queryClient.getQueryData(CART_QUERY_KEYS.list(userId!));
    
    queryClient.setQueryData<CartListResponse>(
      CART_QUERY_KEYS.list(userId!),
      (old = { items: [] }) => ({
        items: old.items.map(item =>
          item.id === id ? { ...item, quantity, updatedAt: new Date().toISOString() } : item
        ),
      })
    );
    
    return { previous };
  },
  
  onError: (_, __, context) => {
    queryClient.setQueryData(CART_QUERY_KEYS.list(userId!), context?.previous);
  },
  
  onSettled: () => {
    // Always refetch after mutation settles (success or error)
    queryClient.invalidateQueries({ queryKey: CART_QUERY_KEYS.details(userId!) });
  },
});
```

## 5. Remove Item Pattern

```typescript
const remove = useMutation({
  mutationFn: (itemId: number) => api.cart.remove(userId!, itemId),
  
  onMutate: async (itemId) => {
    await queryClient.cancelQueries({ queryKey: CART_QUERY_KEYS.list(userId!) });
    const previous = queryClient.getQueryData(CART_QUERY_KEYS.list(userId!));
    
    // Optimistically remove item
    queryClient.setQueryData<CartListResponse>(
      CART_QUERY_KEYS.list(userId!),
      (old = { items: [] }) => ({
        items: old.items.filter(item => item.id !== itemId),
      })
    );
    
    return { previous };
  },
  
  onError: (_, __, context) => {
    queryClient.setQueryData(CART_QUERY_KEYS.list(userId!), context?.previous);
    toast.error("Failed to remove item");
  },
  
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: CART_QUERY_KEYS.details(userId!) });
  },
});
```

## 6. Wishlist Toggle Pattern

Toggle requires knowing current state to decide add vs remove:

```typescript
export const useWishlistMutation = () => {
  const { data } = useWishlist();  // Current wishlist items
  
  const toggle = useMutation({
    mutationFn: async (productId: number) => {
      const isInWishlist = data?.items.some(i => i.productId === productId);
      if (isInWishlist) {
        return api.wishlist.remove(productId);
      } else {
        return api.wishlist.add(productId);
      }
    },
    
    onMutate: async (productId) => {
      await queryClient.cancelQueries({ queryKey: WISHLIST_QUERY_KEYS.list(userId!) });
      const previous = queryClient.getQueryData(WISHLIST_QUERY_KEYS.list(userId!));
      
      const isInWishlist = previous?.items.some(i => i.productId === productId);
      
      queryClient.setQueryData<WishlistResponse>(
        WISHLIST_QUERY_KEYS.list(userId!),
        (old = { items: [] }) => ({
          items: isInWishlist
            ? old.items.filter(i => i.productId !== productId)
            : [...old.items, { productId, createdAt: new Date().toISOString() }],
        })
      );
      
      return { previous, wasInWishlist: isInWishlist };
    },
    
    onError: (_, __, context) => {
      queryClient.setQueryData(WISHLIST_QUERY_KEYS.list(userId!), context?.previous);
    },
  });
  
  return { toggle: toggle.mutate, isToggling: toggle.isPending };
};
```

## 7. Derived State in Query Hook

```typescript
export const useWishlist = () => {
  const query = useQuery({
    queryKey: WISHLIST_QUERY_KEYS.list(userId!),
    queryFn: () => api.wishlist.get(userId!),
    enabled: Boolean(userId),
  });
  
  // Precompute Set for O(1) lookups
  const productIds = useMemo(
    () => new Set(query.data?.items.map(i => i.productId) ?? []),
    [query.data]
  );
  
  const isInWishlist = useCallback(
    (productId: number) => productIds.has(productId),
    [productIds]
  );
  
  return {
    ...query,
    items: query.data?.items ?? [],
    count: query.data?.items.length ?? 0,
    isInWishlist,
  };
};
```

## 8. QueryClient Configuration

```typescript
export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000,      // 5 minutes
      gcTime: 10 * 60 * 1000,        // 10 minutes (was cacheTime in v4)
      refetchOnWindowFocus: false,
      refetchOnReconnect: false,
      retry: 1,
    },
    mutations: {
      retry: false,
    },
  },
});
```

## 9. Placeholders and Suspense

```typescript
// Keep previous data while refetching (no flash-of-empty)
const query = useQuery({
  queryKey: ['logs', 'entries', filter],
  queryFn: () => fetchEntries(filter),
  placeholderData: keepPreviousData,
});

// Or use initialData for SSR hydration
const query = useQuery({
  queryKey: ['products'],
  queryFn: fetchProducts,
  initialData: serverSideProducts,
  staleTime: 60 * 1000,  // Don't refetch for 1 minute
});
```

## Anti-Patterns

| Pattern | Problem | Solution |
|---------|---------|----------|
| Manual cache writes without snapshot | No rollback possible | Always snapshot in onMutate |
| `await queryClient.invalidateQueries` in onMutate | Defeats optimistic purpose | Invalidate in onSuccess/onSettled |
| Forgetting `cancelQueries` | Race condition with in-flight queries | Always cancel first |
| Positive temp IDs | Collide with real IDs | Use negative random IDs |
| Inline mutation options | Recreated every render | Define outside component or useMemo |
