# Hook Patterns Cheatsheet

## Pattern Quick Reference

| Pattern | Use When | Key Characteristics |
|---------|----------|---------------------|
| **Facade** | Wrapping complex APIs | Simplifies interface, hides implementation |
| **Toggle/Manager** | Boolean state with actions | `open()`, `close()`, `toggle()` |
| **Dual-Interface** | Array OR object destructuring | Returns array with attached properties |
| **State Machine** | Multi-step async flows | Explicit states, abort handling |
| **Workspace** | Page-level state aggregation | Multiple queries + local state |
| **Promise Consumer** | React 19 server→client | `use()` + `useOptimistic` |
| **Reducer Editor** | Track dirty state | Local edits vs server state |

## Optimization Quick Reference

### useCallback - USE when:
```typescript
// ✅ Function passed to memoized child
<MemoizedChild onClick={useCallback(() => {}, [deps])} />

// ✅ Function in dependency array
useEffect(() => { callback(); }, [callback]);

// ✅ Function returned from hook
return useMemo(() => ({ handler: memoizedHandler }), [memoizedHandler]);
```

### useCallback - SKIP when:
```typescript
// ❌ Simple inline handler not passed as prop
<button onClick={() => setCount(c => c + 1)}>

// ❌ Function only used in render
const formatted = format(data);
```

### useMemo - USE when:
```typescript
// ✅ Return object from hook (prevent identity changes)
return useMemo(() => ({ cart, addItem, removeItem }), [cart]);

// ✅ Expensive computation
const sorted = useMemo(() => items.sort(complexSort), [items]);

// ✅ Value in dependency array of another hook
const derivedValue = useMemo(() => compute(data), [data]);
useEffect(() => { use(derivedValue); }, [derivedValue]);
```

## Common Mistakes

```typescript
// ❌ Hook calling hook
function useCartWithWishlist() {
  const cart = useCart();
  const wishlist = useWishlist();  // Tight coupling
  return { cart, wishlist };
}

// ✅ Compose at component level
function CartPage() {
  const cart = useCart();
  const wishlist = useWishlist();
  // Use both independently
}
```

```typescript
// ❌ Derived state in useEffect
const [fullName, setFullName] = useState("");
useEffect(() => {
  setFullName(`${first} ${last}`);
}, [first, last]);

// ✅ Compute in render or useMemo
const fullName = `${first} ${last}`;
// or
const fullName = useMemo(() => `${first} ${last}`, [first, last]);
```

```typescript
// ❌ Missing stale closure guard
const startAuth = async () => {
  setState({ loading: true });
  const result = await fetchAuth();
  setState({ data: result });  // Stale if component unmounted
};

// ✅ Guard with ref
const attemptIdRef = useRef(0);
const startAuth = async () => {
  const attemptId = ++attemptIdRef.current;
  setState({ loading: true });
  const result = await fetchAuth();
  if (attemptId !== attemptIdRef.current) return;  // Stale check
  setState({ data: result });
};
```
