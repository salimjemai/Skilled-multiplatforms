# Skilled - MAUI App

Skilled is a cross-platform mobile application that connects users with skilled trade service providers. The app allows users to browse, book, and review various trade services.

## Features

- User authentication (email and password)
- Browse available trade services
- View detailed service provider information
- Book services
- Manage bookings
- User profiles
- Location-based service discovery
- Review system

## Project Structure

- **Models**: Data models representing core entities like User, TradeService, and Booking
- **ViewModels**: MVVM ViewModels that handle UI logic and data binding
- **Views**: XAML UI components
- **Services**: Business logic and API communication layers
- **Helpers**: Utility classes and shared types
- **Data**: Database context and data access

## Technologies

- .NET MAUI for cross-platform UI
- C# and XAML
- Entity Framework Core with PostgreSQL
- REST API communication
- MVVM architecture
- Dependency Injection

## Requirements

- .NET 9.0 SDK
- Visual Studio 2022 or later
- PostgreSQL database server

## Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/Skilled-MAUI.git
   cd Skilled-MAUI
   ```

2. **Create the PostgreSQL schema**
   Connect to your PostgreSQL server and run:
   ```sql
   CREATE SCHEMA skilled_db;
   ```

3. **Set up the connection string using user secrets**
   This keeps your credentials secure and out of source control.
   ```bash
   dotnet user-secrets init --project Skilled.csproj
   dotnet user-secrets set "ConnectionStrings:DefaultConnection" "Host=localhost;Port=5433;Database=skilled;Username=youruser;Password=yourpassword;Search Path=skilled_db" --project Skilled.csproj
   ```
   Replace `youruser` and `yourpassword` with your PostgreSQL credentials.

4. **Apply database migrations**
   ```bash
   dotnet ef database update --startup-project . --context SkilledDbContext --framework net9.0-windows10.0.19041.0
   ```

5. **Build and run the application**
   ```bash
   dotnet build
   dotnet run
   ```

---

## Setup Instructions

(See Quick Start above for the recommended workflow.)

- The connection string is now managed via user secrets, not hardcoded in MauiProgram.cs.
- The API URL can be configured in your app settings or code as needed.

## Database Migration

To add a new migration after making model changes:

```bash
# Example: add a migration for new changes
 dotnet ef migrations add YourMigrationName --startup-project . --context SkilledDbContext --framework net9.0-windows10.0.19041.0
# Apply it
 dotnet ef database update --startup-project . --context SkilledDbContext --framework net9.0-windows10.0.19041.0
```

## Features Comparison with Firebase

This application has been converted from Firebase to PostgreSQL with Entity Framework Core, providing:

1. **Better Data Relationships**: Full relational database capabilities with foreign keys and joins
2. **Advanced Querying**: Complex queries using LINQ and SQL
3. **Data Integrity**: Transactions and constraints ensure data consistency
4. **Scalability**: Better performance for complex operations at scale
5. **Cost Control**: More predictable pricing compared to Firebase

## License

[Specify your license here]

## Contact

[Your contact information]