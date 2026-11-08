# 📅 Appointment Book – Full-Stack Mobile Application

A full-stack mobile application that simplifies appointment scheduling by connecting customers with businesses and service providers. Users can explore businesses, browse available services, manage their profiles, and book appointments through an intuitive mobile interface.

## 🚀 Technologies Used

### Mobile Application (Frontend)
- **Flutter** – Cross-platform mobile development.
- **Dart** – Programming language.
- **Riverpod** – State management.
- **Firebase** – Google authentication integration.

### Backend
- **ASP.NET Core 8 Web API** – RESTful API development.
- **C#** – Backend programming language.
- **PostgreSQL** – Relational database.
- **Npgsql** – Database connectivity.
- **JWT** – Authentication and authorization.
- **BCrypt** – Password hashing.
- **Resend** – Email delivery and OTP verification.

## ✨ Key Features

### Authentication & Authorization
- User registration and login.
- Google Sign-In integration.
- JWT-based authentication.
- Role-based access control.
- Email verification using OTP.
- Secure password hashing.

### Business Management
- Browse available businesses.
- Explore businesses by category.
- View business information and details.
- Discover available services.

### Appointment Management
- Book appointments with businesses.
- View upcoming and previous appointments.
- Update pending appointments.
- Cancel appointments with a cancellation reason.
- Track appointment statuses.

### User Management
- View and manage user profiles.
- Update personal information.
- Change account password.

## 🏗️ Architecture

The project follows a layered backend architecture to maintain separation of concerns, improve maintainability, and support scalability.

**Backend Architecture:**

- **DTO Layer:** Handles data transfer between application layers.
- **Mapping Layer:** Maps between DTOs and application models.
- **Interface Layer:** Defines contracts for data operations.
- **Data Layer:** Handles database operations and stored procedures.
- **Logic Layer:** Contains business logic and application rules.
- **Controller Layer:** Exposes RESTful API endpoints.

## 📂 Project Structure

```text
Appointment_Book_FullStackMobileAPP/
│
├── AppointmentBook_Flutter/       # Flutter mobile application
│   ├── lib/
│   ├── assets/
│   ├── test/
│   └── pubspec.yaml
│
├── AppointmentBook_API/           # ASP.NET Core Web API
│   ├── Controllers/
│   ├── DTOs/
│   ├── DataLayer/
│   ├── LogicLayer/
│   ├── Interfaces/
│   └── Program.cs
│
├── Database/                      # Database scripts
│
└── README.md
```

*Note: Adjust folder names and structure to match the actual repository.*

## ⚙️ Getting Started

### Prerequisites

Make sure you have installed:

- Flutter SDK
- Dart SDK
- .NET 8 SDK
- PostgreSQL
- Android Studio or Visual Studio Code
- Git

### 1. Clone the Repository

```bash
git clone <YOUR_REPOSITORY_URL>
cd Appointment_Book_FullStackMobileAPP
```

### 2. Run the Backend

Navigate to the backend project:

```bash
cd AppointmentBook_API
```

Configure your PostgreSQL connection string and required application settings.

Run the API:

```bash
dotnet restore
dotnet build
dotnet run
```

### 3. Run the Flutter Application

Navigate to the Flutter project:

```bash
cd AppointmentBook_Flutter
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

**Important:** Configure the API base URL according to your environment. For Android emulators, `10.0.2.2` can be used to access the host machine's localhost.

## 🔐 Environment Configuration

For security, keep sensitive information outside source control.

Configure the following where applicable:

- PostgreSQL connection string.
- JWT secret key and authentication settings.
- Firebase configuration.
- Email service API key.
- Other environment-specific settings.

Never commit passwords, API keys, private certificates, or production secrets to GitHub.

## 🧪 Testing

The project includes automated testing practices.

- Flutter widget and unit testing.
- Backend unit testing using xUnit.
- Mocking dependencies using FakeItEasy.
- FluentAssertions for readable test assertions.

## 🛠️ Future Improvements

- Push notifications for appointment updates.
- Online payment integration.
- Advanced business analytics and reporting.
- Appointment reminders.
- Production deployment and CI/CD automation.

## 👨‍💻 Author

**Ahmed Adel El Saeed Mostafa**

- GitHub: [Your GitHub Profile](https://github.com/)
- LinkedIn: [Your LinkedIn Profile](https://www.linkedin.com/)

---

⭐ If you find this project interesting, feel free to explore the repository and give it a star!
