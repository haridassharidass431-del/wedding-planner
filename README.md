# haventra_wedding_planner

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Authentication and data status

The current app uses `MockWeddingRepository`, an in-memory demo data source. Accounts, vendor submissions, approvals, bookings, and profile data reset when the process restarts. The local demo admin is `admin@haventra.local` / `Admin123!`; do not use these credentials in production.

Flutter-side role checks demonstrate the customer, vendor, and admin flows, but do not provide production security. Before deployment, connect a trusted authentication/backend service and enforce role and ownership policies there, including booking access and vendor approval. Approved custom services appear in customer search; pending and rejected submissions do not. No payment integration is included.
