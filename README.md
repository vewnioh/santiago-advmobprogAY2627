# Vergel Adrian Santiago

# INF231

# CTAMOBL Advance Mobile Programming

A new Flutter project that focuses on advanced topics. Covering the mobile to web transaction.

# Lab Activity Instance

## Lab Activity 2: Discussion

In this activity, the application integrates remote REST API data by passing information across three decoupled layers: `ProductService` executes asynchronous HTTP requests, `Product` models deserialize raw JSON payloads into strongly-typed objects, and UI screens render the data dynamically using `FutureBuilder`. The codebase adheres to the MVVM / Service-Provider design pattern, enforcing a strict separation of concerns by isolating network operations from presentation widgets. Global state management is handled using `ThemeProvider` with `ChangeNotifier`, enabling descendant widgets to reactively rebuild whenever state updates occur across the widget tree. This structured architecture improves code maintainability, type safety, and scalability while ensuring seamless data flow between the backend endpoint and the mobile client interface.

