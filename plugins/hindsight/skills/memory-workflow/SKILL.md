---
name: memory-workflow
description: This skill should be used when the user asks to "store decision", "save to memory", "remember this", "recall past decisions", "what did we decide", "check memory", or mentions "hindsight", "memory bank", "retain", "recall", "reflect". Also use proactively when architectural decisions are made, technologies are chosen, bugs are solved, or tradeoffs are discussed.
model: sonnet
---

# Hindsight Memory Workflow

Orchestration guide for using Hindsight memory bank. Retain is async (non-blocking).

## Core Principle: Autonomous Memory Management

The AI assistant manages memory **proactively without being asked**. Two automatic behaviors:

### 1. Check Memory BEFORE Answering

Search memory when the user's prompt involves:

| Trigger | Examples |
|---------|----------|
| Architecture/design | "how to implement", "what approach", "how to structure" |
| Technology choice | "which DB", "which library", "what framework" |
| Pattern/convention | "how do we usually", "is there a standard" |
| Past decision | "why is it this way", "what did we decide" |
| Uncertain context | You're unsure about project-specific details |
| Similar bug/issue | Problem that may have been solved before |
| Infrastructure | Docker/CI/CD/DB configuration questions |

Skip recall for: trivial edits, formatting, confirmations, new code unrelated to past decisions.

Use the **recall skill** to search memory.

### 2. Save Memory AFTER Decisions

After observing any of these in conversation, use the **retain skill**:

| Trigger | Category | Example |
|---------|----------|---------|
| Decision with reasoning | `decisions` | "Let's use X because Y" |
| Technology choice | `tech-stack` | "Chose Redis over Memcached for..." |
| Architectural change | `architecture` | "Moving to event-driven because..." |
| Bug root cause + fix | `bugs` | "Memory leak caused by unclosed connections" |
| Convention established | `conventions` | "From now on, all APIs follow..." |
| Tradeoff made | `tradeoffs` | "Sacrificing type safety for backward compat" |
| Constraint/workaround | `lessons` | "X doesn't work because Y, using Z" |
| Negative decision | `decisions` | "We do NOT use X because Y" |
| User repeats context | `lessons` | User explains same thing twice — save it |
| Explicit request | any | "remember", "save this", "запомни" |
| Dependency with reasoning | `tech-stack` | "Added axios — better interceptors than fetch" |
| Infrastructure change | `architecture` | "Multi-stage Docker for smaller images" |

### 3. Use Reflect for Analysis

When evaluating approaches against existing patterns, looking for trends, or making recommendations based on project history:

Use the **reflect skill** for AI-powered analysis.

## Action Skills

Execution details are in dedicated action skills:

- **retain skill** — saves content to memory (async, non-blocking)
- **recall skill** — searches memory bank
- **reflect skill** — gets AI analysis from memory bank
