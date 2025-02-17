# Loony
[![Test Matrix](https://github.com/disruptek/cps/workflows/CI/badge.svg)](https://github.com/shayanhabibi/loony/actions?query=workflow%3ACI)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/shayanhabibi/loony?style=flat)](https://github.com/shayanhabibi/loony/releases/latest)
![Minimum supported Nim version](https://img.shields.io/badge/nim-1.5.1%2B-informational?style=flat&logo=nim)
[![License](https://img.shields.io/github/license/shayanhabibi/loony?style=flat)](#license)

>*"Don't let me block you" - Araq*
>
>*"We didn't have a good story about migrating continuations between threads." - Disruptek*

Have you ever asked yourself what would a lock-free MPMC queue look like in nim?

What about a lock-free MPMC queue designed on an algorithm built for speed and memory safety?

What about that algorithm implemented by some ***loonatics***?

Enter **Loony**

>*"C'mon man... 24,000 threads and 500,000,000 continuations... which are written in "normal" nim." - Disruptek*
>
>*"OK, time to get my monies worth from all my cores" - saem*
>
>*"My eyes are bleeding" - cabboose*

## About

> A massive thank you to the author Oliver Giersch who proposed this algorithm and for being so kind as to have a look at our implementation and review it! We wish nothing but the best for the soon to be Dr Giersch.


Loony is a 100% Nim-lang implementation of the algorithm depicted by Giersch & Nolte in ["Fast
and Portable Concurrent FIFO Queues With Deterministic Memory Reclamation"](papers/GierschEtAl.pdf).

The algorithm was chosen to help progress the concurrency story of [CPS](https://github.com/disruptek/cps) for which this was bespokingly made.

After adapting the algorithm to nim CPS, disruptek adapted the queue for **any ref object** and was instrumental in ironing out the bugs and improving the performance of Loony.

## What can it do

> While the following is possible; this is only by increasing the alignment our 'node' pointers to 16 which would invariably effect performance.
>- Lock-free consumption by up to **32,255** threads
>- Lock-free production by up to **64,610** threads

With the 11 bit aligned implementation we have:
- Lock-free consumption up to **512** threads
- Lock-free production up to **1,025** threads
- Memory-leak free under **ARC**
- Can pass ANY ref object between threads; however:
  - Is perfectly designed for passing Continuations between threads
  - :warning: Memory safety is up to the user, data races accessing memory associated with the reference are not prevented (*currently :wink:*)

## Issues

**Loony queue only works on ARC**.

ORC is not supported (See [Issue #4](https://github.com/shayanhabibi/loony/issues/4))

## Installation

Download with `nimble install loony` (CPS dependency for tests) or directly from the source.

### How to use

Simple:

```nim
import pkg/loony

type AnyRefObject = ref object

var loonyQueue = initLoonyQueue[AnyRefObject]()
# loony queue is a ref object itself

var aro = new AnyRefObject

loonyQueue.push aro
# Enqueue objects onto the queue

var el = loonyQueue.pop
# Dequeue objects from the queue
```

Not much else to it!

## Benchmarks

TBD

## Current State

*"It works" - Disruptek*

## What are Continuations?

If you've somehow missed the next big thing for nim; see [CPS](https://github.com/disruptek/cps)
