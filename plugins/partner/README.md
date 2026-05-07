# Partner Plugin

Collaborative learning and guidance skills.

## Skills

### partner:mentor

Transforms agent from "doer" to "guide". When active, the agent analyzes tasks as usual but guides the user through execution rather than implementing directly.

**Usage:**
```bash
/partner:mentor --steps      # Detailed commands with explanations
/partner:mentor --guide      # Approach descriptions, user picks tools
/partner:mentor --phases     # High-level outline only
/partner:mentor --steps /fix # Guide user through /fix skill
/partner:mentor --off        # Exit mentor mode
```

**Features:**
- Three granularity modes: steps, guide, phases
- Checkpoint validation with Socratic questioning
- Session persistence for resumable learning
- Wraps other skills for guided execution

## Installation

```bash
./setup.sh --plugins partner
```
