package middleware

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
)

func TestCORSAllowsFlutterLoopbackDevelopmentPorts(t *testing.T) {
	gin.SetMode(gin.TestMode)
	router := gin.New()
	router.Use(CORS("http://localhost:3000"))
	router.POST("/api/auth/register", func(c *gin.Context) {
		c.Status(http.StatusCreated)
	})

	for _, origin := range []string{
		"http://localhost:50223",
		"http://127.0.0.1:50223",
		"http://[::1]:50223",
	} {
		t.Run(origin, func(t *testing.T) {
			request := httptest.NewRequest(http.MethodOptions, "/api/auth/register", nil)
			request.Header.Set("Origin", origin)
			request.Header.Set("Access-Control-Request-Method", http.MethodPost)
			request.Header.Set("Access-Control-Request-Headers", "content-type")
			response := httptest.NewRecorder()

			router.ServeHTTP(response, request)

			if response.Code != http.StatusNoContent {
				t.Fatalf("expected preflight status %d, got %d", http.StatusNoContent, response.Code)
			}
			if got := response.Header().Get("Access-Control-Allow-Origin"); got != origin {
				t.Fatalf("expected allowed origin %q, got %q", origin, got)
			}
		})
	}
}

func TestCORSRejectsUnconfiguredRemoteOrigins(t *testing.T) {
	gin.SetMode(gin.TestMode)
	router := gin.New()
	router.Use(CORS("http://localhost:3000"))
	router.POST("/api/auth/register", func(c *gin.Context) {
		c.Status(http.StatusCreated)
	})

	request := httptest.NewRequest(http.MethodOptions, "/api/auth/register", nil)
	request.Header.Set("Origin", "https://example.com")
	request.Header.Set("Access-Control-Request-Method", http.MethodPost)
	request.Header.Set("Access-Control-Request-Headers", "content-type")
	response := httptest.NewRecorder()

	router.ServeHTTP(response, request)

	if got := response.Header().Get("Access-Control-Allow-Origin"); got != "" {
		t.Fatalf("expected no CORS permission for remote origin, got %q", got)
	}
}

func TestCORSDoesNotEnableLoopbackWildcardForRemoteConfiguration(t *testing.T) {
	gin.SetMode(gin.TestMode)
	router := gin.New()
	router.Use(CORS("https://shortlab.example"))
	router.POST("/api/auth/register", func(c *gin.Context) {
		c.Status(http.StatusCreated)
	})

	request := httptest.NewRequest(http.MethodOptions, "/api/auth/register", nil)
	request.Header.Set("Origin", "http://localhost:50223")
	request.Header.Set("Access-Control-Request-Method", http.MethodPost)
	request.Header.Set("Access-Control-Request-Headers", "content-type")
	response := httptest.NewRecorder()

	router.ServeHTTP(response, request)

	if got := response.Header().Get("Access-Control-Allow-Origin"); got != "" {
		t.Fatalf("expected no CORS permission for loopback origin with remote configuration, got %q", got)
	}
}
