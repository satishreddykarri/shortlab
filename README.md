
# 🔗 ShortLab

**A URL Shortening Platform built with Go and PostgreSQL.**

ShortLab is a URL shortening platform that transforms long URLs into short, shareable links. It is designed with a focus on backend engineering, RESTful API development, database management, and scalable application architecture.

## 🚀 Tech Stack

- **Backend:** Go (Golang), Gin
- **ORM:** GORM
- **Database:** PostgreSQL
- **Containerization:** Docker
- **Development Environment:** Docker Compose
- **API Documentation:** Swagger
- **Frontend:** Flutter

## ✨ Features

- URL shortening and redirection
- Multiple short-code generation strategies
- Custom URL aliases
- JWT-based user authentication
- Email verification
- Shortened URL management
- Link analytics
- RESTful API architecture
- PostgreSQL integration
- Docker-based development environment

## 🏗️ Architecture

ShortLab follows a layered backend architecture to ensure separation of concerns, maintainability, and extensibility.

```text
Client Application
       |
       v
   REST APIs
       |
       v
  Handler Layer
       |
       v
  Service Layer
       |
       v
 Repository Layer
       |
       v
   PostgreSQL
```

## 📁 Project Structure

```text
shortlab/
├── cmd/
├── config/
├── internal/
│   ├── handler/
│   ├── service/
│   ├── repository/
│   ├── model/
│   └── middleware/
├── docs/
├── migrations/
├── Dockerfile
├── docker-compose.yml
├── go.mod
├── go.sum
└── README.md
```

*The structure above represents the intended architecture. Update it to reflect the actual repository.*

## ⚙️ Getting Started

### Prerequisites

Make sure you have the following installed:

- [Go](https://go.dev/dl/)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Git](https://git-scm.com/)

### 1. Clone the Repository

```bash
git clone https://github.com/satishreddykarri/shortlab.git
cd shortlab
```

### 2. Configure Environment Variables

Create a `.env` file in the project root.

```env
APP_PORT=8080

DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=your_password
DB_NAME=shortlab
DB_SSLMODE=disable
```

Update the values according to your local configuration.

### 3. Start PostgreSQL

Start the database using Docker Compose:

```bash
docker compose up -d
```

Verify that the container is running:

```bash
docker ps
```

### 4. Install Dependencies

```bash
go mod download
```

### 5. Run the Application

```bash
go run ./cmd/server
```

The application will be available at:

```text
http://localhost:8080
```

*Adjust the commands and configuration according to the actual project setup.*

## 🔑 Short Code Generation Strategies

ShortLab explores different approaches to generating unique short identifiers.

| Strategy | Description |
|---|---|
| Base62 | Generates compact alphanumeric identifiers. |
| Hash-based | Generates identifiers using hashing techniques. |
| Random | Generates randomly selected identifiers. |
| UUID | Uses universally unique identifiers. |
| Custom Alias | Allows users to define custom short codes. |

## 📖 API Documentation

ShortLab provides RESTful APIs for URL creation, management, and redirection.

Swagger documentation (when configured):

```text
http://localhost:8080/swagger/index.html
```

## 🛣️ Roadmap

- [x] Initial backend setup
- [x] PostgreSQL integration
- [x] Docker-based development environment
- [ ] URL shortening and redirection
- [ ] User authentication and authorization
- [ ] Custom URL aliases
- [ ] URL expiration
- [ ] Link analytics
- [ ] Rate limiting
- [ ] Automated testing
- [ ] Cloud deployment

Update the roadmap as implementation progresses.

## 🔮 Future Enhancements

- QR code generation
- Advanced link analytics
- Caching for frequently accessed URLs
- Custom domain support
- Improved security and rate limiting
- Scalable deployment architecture

## 👨‍💻 Author

**Satish Reddy**

- GitHub: [satishreddykarri](https://github.com/satishreddykarri)
- LinkedIn: [Connect with me](https://www.linkedin.com/)

---

⭐ If you find this project interesting, consider giving it a star!

**Built with ❤️ using Go and PostgreSQL.**
