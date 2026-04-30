---
name: nextjs:hooks
description: "Design production-grade React hooks. Use for: facade/wrapper hooks, state machines, TanStack Query composition, dual-interface hooks, workspace aggregation, React 19 patterns."
---

# Advanced React Hook Patterns

Design reusable, performant custom hooks using proven production patterns.

## Pattern Decision Tree

```
What does your hook need to do?
├── Wrap TanStack Query → Facade Pattern
├── Manage boolean state → Toggle/Manager Pattern
├── Multi-step async flow → State Machine Pattern
├── Aggregate page state → Workspace Pattern
├── Provide dual API → Dual-Interface Pattern
└── Bridge Server→Client → Promise Consumer Pattern
```

## 1. Facade Pattern

Wrap complex APIs (TanStack Query, Context, etc.) into simple interfaces.

### Query Facade
```typescript
// hooks/cart/queries/useCart.ts
export const useCart = () => {
  const { data: session } = useSession();
  const userId = session?.user?.id;
  
  const query = useQuery({
    queryKey: CART_QUERY_KEYS.cartList(userId!),
    queryFn: () => fetchCart(userId!),
    enabled: Boolean(userId),
  });
  
  // Derived state
  const getCartItemById = useCallback(
    (id: number) => query.data?.items.find(item => item.id === id),
    [query.data]
  );
  
  return { ...query, items: query.data?.items ?? [], getCartItemById };
};
```

### Mutation Facade (Multiple Operations)
```typescript
// hooks/cart/mutations/useCartMutation.ts
export const useCartMutation = () => {
  const { data: session } = useSession();
  const userId = session?.user?.id;
  const queryClient = useQueryClient();
  
  const add = useMutation({
    mutationFn: (params: AddToCartParams) => addToCart(userId!, params),
    onMutate: async (params) => { /* optimistic update */ },
    onError: (_, __, context) => { /* rollback */ },
    onSuccess: () => queryClient.invalidateQueries({ queryKey: CART_QUERY_KEYS.cartDetails(userId!) }),
  });
  
  const update = useMutation({ /* similar */ });
  const remove = useMutation({ /* similar */ });
  const clear = useMutation({ /* similar */ });
  
  return {
    add: add.mutate, update: update.mutate, remove: remove.mutate, clear: clear.mutate,
    isAdding: add.isPending, isUpdating: update.isPending,
    isRemoving: remove.isPending, isClearing: clear.isPending,
    addError: add.error, updateError: update.error,
  };
};
```

### Context Facade with Guard
```typescript
export const useCart = () => {
  const context = useContext(CartStateContext);
  if (context === undefined) {
    throw new Error("useCart must be used within a CartProvider");
  }
  return useMemo(() => context, [context]);
};
```

## 2. Toggle/Manager Pattern

Wrap boolean state with semantic actions.

### Basic Toggle
```typescript
export function useManager(initial = false) {
  const [active, setActive] = useState(initial);
  
  const toggle = useCallback(() => setActive(v => !v), []);
  const open = useCallback(() => setActive(true), []);
  const close = useCallback(() => setActive(false), []);
  const set = useCallback((value: boolean) => setActive(value), []);
  
  return useMemo(
    () => ({ active, toggle, open, close, set }),
    [active, toggle, open, close, set]
  );
}
```

### Dual-Interface Pattern
Returns both array (positional) and object (named) access:
```typescript
export type StateType = [boolean, () => void, () => void, () => void] & {
  state: boolean;
  open: () => void;
  close: () => void;
  toggle: () => void;
};

export function useToggleState(initialState = false): StateType {
  const [state, setState] = useState(initialState);
  const open = useCallback(() => setState(true), []);
  const close = useCallback(() => setState(false), []);
  const toggle = useCallback(() => setState(v => !v), []);
  
  // Create array and attach named properties
  const hookData = [state, open, close, toggle] as StateType;
  hookData.state = state;
  hookData.open = open;
  hookData.close = close;
  hookData.toggle = toggle;
  
  return hookData;
}

// Usage - both work:
const [isOpen, openModal, closeModal] = useToggleState();
const { state, open, close } = useToggleState();
```

## 3. State Machine Pattern

Manage multi-step async flows with explicit state transitions.

```typescript
type AuthFlowState = {
  provider: string | null;
  isAuthenticating: boolean;
  error: string | null;
  authUrl: string | null;
  isPolling: boolean;
};

const INITIAL_STATE: AuthFlowState = {
  provider: null,
  isAuthenticating: false,
  error: null,
  authUrl: null,
  isPolling: false,
};

export function useAuthFlow() {
  const [state, setState] = useState<AuthFlowState>(INITIAL_STATE);
  const abortControllerRef = useRef<AbortController | null>(null);
  const attemptIdRef = useRef(0);  // Guards stale closures
  
  const startAuth = useCallback(async (provider: string) => {
    const attemptId = ++attemptIdRef.current;
    abortControllerRef.current?.abort();
    abortControllerRef.current = new AbortController();
    
    setState(s => ({ ...s, provider, isAuthenticating: true, error: null }));
    
    try {
      const { authUrl } = await initiateOAuth(provider, abortControllerRef.current.signal);
      if (attemptId !== attemptIdRef.current) return;  // Stale check
      
      setState(s => ({ ...s, authUrl, isPolling: true }));
      window.open(authUrl, '_blank', 'noopener,noreferrer');
      
      // Start polling...
    } catch (err) {
      if (attemptId !== attemptIdRef.current) return;
      setState(s => ({ ...s, isAuthenticating: false, error: (err as Error).message }));
    }
  }, []);
  
  const cancelAuth = useCallback(() => {
    abortControllerRef.current?.abort();
    setState(INITIAL_STATE);
  }, []);
  
  return useMemo(
    () => ({ ...state, startAuth, cancelAuth }),
    [state, startAuth, cancelAuth]
  );
}
```

## 4. Workspace Pattern

Aggregate multiple queries + local state for a page's concern.

```typescript
export function useLogsWorkspace() {
  // Local filter state
  const [selectedSource, setSelectedSource] = useState<LogsSourceFilter>('all');
  const [search, setSearch] = useState('');
  const deferredSearch = useDeferredValue(search.trim());  // Built-in debounce
  
  // Multiple independent queries
  const configQuery = useQuery({
    queryKey: ['logs', 'config'],
    queryFn: fetchLogsConfig,
  });
  
  const sourcesQuery = useQuery({
    queryKey: ['logs', 'sources'],
    queryFn: fetchLogsSources,
    refetchInterval: 15_000,
  });
  
  const entriesQuery = useQuery({
    queryKey: ['logs', 'entries', selectedSource, deferredSearch],
    queryFn: () => fetchLogsEntries({ source: selectedSource, search: deferredSearch }),
    placeholderData: keepPreviousData,  // Avoid flash-of-empty
    refetchInterval: 10_000,
  });
  
  // Derived state
  const selectedEntry = useMemo(
    () => entriesQuery.data?.find(e => e.id === selectedId),
    [entriesQuery.data, selectedId]
  );
  
  return {
    // Queries
    configQuery, sourcesQuery, entriesQuery,
    // Filters
    selectedSource, setSelectedSource, search, setSearch,
    // Derived
    selectedEntry,
  };
}
```

## 5. Promise Consumer Pattern (React 19)

Bridge Server Component data to Client hooks via Promise.

```typescript
// Server Component
export default async function Layout({ children }) {
  const cartPromise = getCart();  // NOT awaited
  return <CartProvider cartPromise={cartPromise}>{children}</CartProvider>;
}

// Client Context
type CartContextType = { cartPromise: Promise<Cart | undefined> };
const CartContext = createContext<CartContextType | undefined>(undefined);

// Client Hook
export function useCart() {
  const { cartPromise } = useContext(CartContext)!;
  const initialCart = use(cartPromise);  // Suspends until resolved
  
  const [optimisticCart, updateOptimisticCart] = useOptimistic(
    initialCart,
    cartReducer
  );
  
  const addCartItem = useCallback((variant: ProductVariant, product: Product) => {
    updateOptimisticCart({ type: "ADD_ITEM", payload: { variant, product } });
  }, [updateOptimisticCart]);
  
  return useMemo(
    () => ({ cart: optimisticCart, addCartItem }),
    [optimisticCart, addCartItem]
  );
}
```

## 6. Reducer-Based Editor Pattern

Track dirty state separately from server state.

```typescript
type EditState = {
  localContent: string | null;  // null = not dirty
  lastServerContent: string;
};

type EditAction =
  | { type: 'EDIT'; content: string; serverContent: string }
  | { type: 'RESET'; serverContent: string }
  | { type: 'SAVE_SUCCESS'; content: string };

function editReducer(state: EditState, action: EditAction): EditState {
  switch (action.type) {
    case 'EDIT':
      // If content matches server, clear local edits
      if (action.content === action.serverContent) {
        return { localContent: null, lastServerContent: action.serverContent };
      }
      return { localContent: action.content, lastServerContent: action.serverContent };
    case 'RESET':
      return { localContent: null, lastServerContent: action.serverContent };
    case 'SAVE_SUCCESS':
      return { localContent: null, lastServerContent: action.content };
  }
}

export function useConfigEditor() {
  const { data: serverConfig } = useQuery({ queryKey: ['config'], queryFn: fetchConfig });
  const [editState, dispatch] = useReducer(editReducer, {
    localContent: null,
    lastServerContent: serverConfig ?? '',
  });
  
  const isDirty = editState.localContent !== null;
  const currentContent = editState.localContent ?? editState.lastServerContent;
  
  const handleEdit = (content: string) => {
    dispatch({ type: 'EDIT', content, serverContent: serverConfig ?? '' });
  };
  
  return { currentContent, isDirty, handleEdit, dispatch };
}
```

## 7. Optimization Guidelines

### When to use useCallback
- Function passed to memoized child components
- Function in dependency array of useEffect/useMemo
- Function returned from hook (if consumers might use it in deps)

### When to use useMemo
- Return object from hook (prevents re-renders on new object identity)
- Expensive derived computations
- Values used in dependency arrays

### When NOT to optimize
- Simple state setters (already stable from useState)
- Inline event handlers not passed as props
- Primitive return values (no identity issues)

## Anti-Patterns

| Pattern | Problem | Solution |
|---------|---------|----------|
| Hook calling hook | Tight coupling | Compose at component level |
| `useEffect` for derived state | Extra render | `useMemo` or compute in render |
| Missing deps in useCallback | Stale closures | Add deps or use ref |
| `eslint-disable exhaustive-deps` | Hidden bugs | Restructure with refs |
| 30 single-field setters in reducer | No atomicity benefit | Use multiple `useState` |
