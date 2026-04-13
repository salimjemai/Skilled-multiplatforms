# Skilled Multiplatforms

Skilled is best envisioned as a trust-first marketplace for home services and skilled trades. The product connects customers with local professionals for work like plumbing, electrical, HVAC, carpentry, landscaping, cleaning, and general handyman services. It is not just a directory of providers; it is intended to cover the full job lifecycle from discovery to booking to payment to post-job review.

This repository already reflects that broader vision. It contains a shared domain and data model, a .NET MAUI cross-platform app, a native iOS app, and an ASP.NET Core API project. The strongest interpretation of the project is:

- A multi-platform marketplace brand with one shared business domain
- A customer and provider experience built around trust, scheduling, and convenience
- A codebase moving from prototype scaffolding into a production-grade platform

## Product Vision

The clearest north star for Skilled is:

**"Make hiring a trusted local trade professional feel as easy, transparent, and safe as booking a modern consumer service."**

That means the product should be shaped around a few core promises:

- Customers can quickly find the right pro for a real-world job.
- Providers can present themselves professionally and win work without friction.
- Both sides can communicate clearly, agree on scope, schedule work, and handle payment safely.
- Trust signals like ratings, reviews, verification, availability, and history are central to the experience.

In other words, Skilled should feel closer to a service operating system for local trades than a simple listings app.

## What The Repo Says The Product Is

From the current domain models and app structure, the platform is already designed around these capabilities:

- **Identity and roles**: users, providers, authentication, profiles
- **Service marketplace**: trade categories, provider listings, service offerings, pricing
- **Booking flow**: scheduling, booking state, totals, booking lifecycle
- **Payments**: multiple payment methods, transaction tracking, refund/dispute concepts
- **Messaging**: chats, previews, unread states, customer-provider communication
- **Reputation**: reviews and ratings
- **Location awareness**: addresses and service geography

That’s a strong foundation. It means the project should be envisioned as a vertically integrated marketplace for skilled labor, not just a UI experiment.

## Current Architecture

### 1. Shared domain and data layer

The `Skilled.Data` project defines the central business entities:

- `User`
- `ServiceProvider`
- `TradeService`
- `TradeCategory`
- `Booking`
- `Payment`
- `Review`
- `ChatMessage`
- `ChatPreview`
- `Location`

The EF Core `SkilledDbContext` models the relational backbone for the platform and sets a default PostgreSQL schema of `skilled_db`.

This is the heart of the repo. It is the clearest expression of what the product wants to become.

### 2. Shared services layer

`Skilled.Services` provides reusable service abstractions for:

- authentication
- user retrieval and updates
- trade service retrieval and CRUD
- preference/local token storage

These services are written as if they are meant to sit between the UI and a real backend API. That’s a healthy architectural direction, even though some implementations are still placeholder-oriented.

### 3. .NET MAUI app

`SkillMAUI` is the cross-platform client bet.

It currently shows the shape of a shared app for:

- login/register
- home/discovery
- service lists and details
- bookings
- messages
- settings/profile

The MAUI side is a good foundation for broad platform coverage, but several pages are still placeholder screens and some bindings appear ahead of the underlying model implementation. That suggests this app is in an early integration phase rather than production-ready.

### 4. Native iOS app

`SKILLED-SPM` is the more feature-rich native iOS exploration.

Compared with the MAUI app, the iOS project goes deeper into:

- custom UIKit flows
- chat and conversation UX
- payment method management
- payment-provider-specific UI
- Firebase-backed auth/data patterns
- more detailed provider/profile interactions

This part of the repo reads like a richer product prototype, especially around customer experience and native mobile polish.

### 5. ASP.NET Core API

`Skilled.API` is currently the least mature layer.

Right now it is still close to the default starter template and exposes only the sample weather endpoint. That means the domain and clients are ahead of the backend. The platform concept is real, but the production API still needs to be built to support the flows already implied by the clients and services.

## Honest Read On Current State

The repository is promising, but it is in a transitional state.

### What feels well defined

- The marketplace concept
- The core business entities
- The desired customer journey
- The importance of trust, ratings, chat, booking, and payments
- The intent to support multiple platforms

### What still feels incomplete

- Production API implementation
- Alignment between some UI bindings and actual model properties
- End-to-end data flow consistency across MAUI, iOS, and backend
- Test coverage and integration validation
- Environment/configuration standardization

So the right way to talk about the project today is:

**Skilled is a clearly defined multi-platform marketplace product with a strong domain model and multiple client implementations, currently moving from prototype/proof-of-concept toward a consolidated production platform.**

## Recommended Vision For The Team

If we were describing how this project should be envisioned internally, I would phrase it like this:

### Skilled is a two-sided marketplace

There are two primary users:

- **Customers** who need trusted help with real-world jobs
- **Service providers** who want to advertise skills, receive bookings, message clients, and get paid

Every major feature should support one or both sides of that marketplace.

### Skilled should compete on trust, not just convenience

Local service marketplaces succeed when users feel safe hiring someone. The product should emphasize:

- provider verification
- transparent ratings and reviews
- pricing clarity
- booking confirmations
- payment confidence
- communication history
- provider professionalism

### Skilled should own the full service journey

The ideal user flow is:

1. Discover providers by category and location
2. Compare trust signals and offerings
3. View service details and provider profiles
4. Request or book a job
5. Message the provider
6. Pay securely
7. Leave a review and build long-term trust

That full lifecycle is already visible in the data model, so the product strategy should lean into it.

### Skilled should converge toward one shared platform contract

Right now the repo contains multiple platform approaches:

- native iOS with Firebase-era patterns
- MAUI with shared C# services and PostgreSQL/EF direction
- an ASP.NET API that still needs implementation

The long-term vision should be one canonical backend contract with:

- a consistent auth model
- one source of truth for users, providers, services, bookings, chats, and payments
- thin clients that consume the same platform capabilities

That will make the repo easier to scale and maintain.

## Suggested Strategic Direction

If the goal is to turn this into a durable product, the order of priorities should be:

### 1. Make the backend real

Build the API around the domain that already exists.

Recommended first API areas:

- `/auth`
- `/users`
- `/providers`
- `/services`
- `/bookings`
- `/payments`
- `/reviews`
- `/messages`

Until this exists, the clients will remain partly disconnected from the product vision.

### 2. Choose the system of record

The repo currently shows two backend directions:

- Firebase in the native iOS project
- PostgreSQL + EF Core in the shared .NET projects

For long-term coherence, pick one authoritative platform path and move the clients toward it deliberately.

### 3. Standardize the shared product contract

Create shared DTOs, API response shapes, auth flows, and status enums that line up across:

- database entities
- API models
- MAUI client
- iOS client

This will remove drift and reduce platform-specific behavior mismatches.

### 4. Decide the platform strategy

There are two sensible interpretations:

- **Primary strategy**: MAUI becomes the main shipping app, with iOS kept only as reference or phased out
- **Dual-client strategy**: native iOS stays a first-class client for premium UX, while MAUI covers cross-platform reach

Either is valid, but the repo should eventually reflect a conscious choice.

### 5. Harden the marketplace loop

Once the platform contract is stable, the highest-value product work is:

- provider onboarding and verification
- service discovery and filtering
- booking workflow completion
- messaging reliability
- payment processing hardening
- review and reputation mechanics

Those are the features that turn the concept into a real marketplace.

## Repository Layout

```text
.
├── Skilled.sln                # Root .NET solution
├── Skilled.API/               # ASP.NET Core backend API
├── Skilled.Data/              # Shared EF Core models and DbContext
├── Skilled.Services/          # Shared business/application services
├── Skilled.Tests/             # Test project scaffold
├── SkillMAUI/                 # .NET MAUI cross-platform client
└── SKILLED-SPM/               # Native iOS application
```

## Tech Stack

### Shared .NET stack

- .NET 8
- C#
- Entity Framework Core
- PostgreSQL via Npgsql
- ASP.NET Core

### Cross-platform app

- .NET MAUI
- XAML
- CommunityToolkit.MVVM

### Native iOS app

- Swift
- UIKit
- Firebase Auth / Firestore
- Apple Pay related platform integrations

## How To Think About Each App

### `SkillMAUI`

Best viewed as the cross-platform product shell and shared .NET application direction.

Use this project to:

- validate shared architecture
- keep business logic close to the shared services layer
- target Android, iOS, Mac Catalyst, and Windows where needed

### `SKILLED-SPM`

Best viewed as the more advanced native mobile UX prototype, especially for iOS-specific flows like messaging and payments.

Use this project to:

- experiment with native polish
- preserve working iOS product ideas
- inform what the shared MAUI experience should eventually match

### `Skilled.API`

Best viewed as the future backbone of the whole platform.

Use this project to:

- centralize auth
- expose the marketplace domain as real APIs
- support both client implementations
- become the single system of record if PostgreSQL is the chosen backend direction

## Development Notes

### Important reality check

This repo is not yet fully unified end-to-end.

Examples of current gaps:

- the API is still starter-level
- some MAUI screens are placeholders
- some MAUI views reference richer provider fields than the shared C# model currently exposes
- the iOS app still contains Firebase-based flows that do not yet match the .NET backend direction

That is normal for a project in transition, but it should be explicit so future work stays focused.

## Recommended Near-Term Roadmap

### Phase 1: Platform alignment

- Implement core API endpoints
- finalize auth strategy
- confirm PostgreSQL schema and migrations
- define shared API contracts

### Phase 2: End-to-end customer journey

- browse services
- provider detail page
- create booking
- booking history
- messaging
- payment initiation

### Phase 3: Trust and marketplace depth

- provider onboarding
- verification workflows
- reviews and ratings
- availability and scheduling
- cancellation/refund policies

### Phase 4: Production hardening

- tests
- error handling
- analytics
- monitoring
- CI/CD
- secrets/config management

## Local Setup

Because the repo contains multiple app styles and an API, setup will vary by target. The current .NET direction appears to be:

### Prerequisites

- .NET 8 SDK
- Xcode for the native iOS app
- PostgreSQL
- an IDE such as Visual Studio, Rider, or VS Code

### .NET projects

Typical projects to work with:

- `Skilled.API`
- `Skilled.Data`
- `Skilled.Services`
- `SkillMAUI`

### Database

The EF Core context uses the PostgreSQL schema:

```sql
CREATE SCHEMA skilled_db;
```

Then configure your connection string with user secrets or environment-specific settings.

## Final Take

The strongest way to envision this project is:

**Skilled is a multi-platform marketplace platform for trusted local trade services, with a strong shared domain model and promising client experiences, now needing backend consolidation and product alignment to become a cohesive production system.**

That is already visible in the codebase. The next chapter is not inventing the product from scratch; it is tightening the architecture so the existing product vision can actually ship cleanly.
