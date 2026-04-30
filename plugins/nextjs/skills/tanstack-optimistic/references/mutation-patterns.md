# TanStack Query Mutation Patterns

## Mutation Lifecycle

```
mutate() called
    ↓
onMutate (sync) → Return context for rollback
    ↓
mutationFn (async) → API call
    ↓
┌───────────────┬───────────────┐
│   onSuccess   │   onError     │
│  (if resolved)│ (if rejected) │
└───────────────┴───────────────┘
    ↓
onSettled (always, after success or error)
```

## Quick Reference

```typescript
useMutation({
  mutationFn: async (params) => api.call(params),
  
  // BEFORE API call - sync, runs immediately
  onMutate: async (params) => {
    await queryClient.cancelQueries({ queryKey });
    const previous = queryClient.getQueryData(queryKey);
    queryClient.setQueryData(queryKey, optimisticUpdate);
    return { previous };  // Context for rollback
  },
  
  // API succeeded
  onSuccess: (data, variables, context) => {
    // Replace temp data with real data
    // Or just invalidate to refetch
    queryClient.invalidateQueries({ queryKey });
  },
  
  // API failed
  onError: (error, variables, context) => {
    // Rollback optimistic update
    queryClient.setQueryData(queryKey, context.previous);
    toast.error(error.message);
  },
  
  // Always runs after success or error
  onSettled: (data, error, variables, context) => {
    // Good place for cleanup or guaranteed invalidation
  },
});
```

## Temp ID Strategies

```typescript
// Negative random (recommended)
const tempId = -Math.floor(Math.random() * 1e9);

// UUID-based
const tempId = `temp-${crypto.randomUUID()}`;

// Timestamp-based
const tempId = -Date.now();
```

## Cache Update Patterns

### Replace Single Item
```typescript
queryClient.setQueryData(queryKey, (old) => ({
  items: old.items.map(item => 
    item.id === targetId ? updatedItem : item
  ),
}));
```

### Add Item
```typescript
queryClient.setQueryData(queryKey, (old) => ({
  items: [newItem, ...old.items],
}));
```

### Remove Item
```typescript
queryClient.setQueryData(queryKey, (old) => ({
  items: old.items.filter(item => item.id !== targetId),
}));
```

### Upsert (Add or Update)
```typescript
queryClient.setQueryData(queryKey, (old) => {
  const idx = old.items.findIndex(i => i.id === item.id);
  if (idx >= 0) {
    const updated = [...old.items];
    updated[idx] = { ...updated[idx], ...item };
    return { items: updated };
  }
  return { items: [item, ...old.items] };
});
```

## Invalidation Strategies

```typescript
// Invalidate single query
queryClient.invalidateQueries({ queryKey: ['cart', userId] });

// Invalidate all queries starting with prefix
queryClient.invalidateQueries({ queryKey: ['cart'] });

// Invalidate exact match only
queryClient.invalidateQueries({ queryKey: ['cart', userId], exact: true });

// Invalidate and wait for refetch
await queryClient.invalidateQueries({ queryKey: ['cart'] });

// Remove from cache entirely
queryClient.removeQueries({ queryKey: ['cart', userId] });
```
