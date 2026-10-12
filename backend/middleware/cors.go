package middleware

import (
	"net"
	"net/url"
	"strings"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func CORS(frontendURL string) gin.HandlerFunc {
	config := cors.DefaultConfig()

	config.AllowOriginFunc = func(origin string) bool {
		return origin == frontendURL ||
			(isLoopbackHTTPOrigin(frontendURL) && isLoopbackHTTPOrigin(origin))
	}
	config.AllowMethods = []string{
		"GET",
		"POST",
		"PUT",
		"PATCH",
		"DELETE",
		"OPTIONS",
	}
	config.AllowHeaders = []string{
		"Origin",
		"Content-Type",
		"Accept",
		"Authorization",
	}
	config.MaxAge = 12 * time.Hour

	return cors.New(config)
}

func isLoopbackHTTPOrigin(value string) bool {
	origin, err := url.Parse(value)
	if err != nil ||
		origin.Scheme != "http" ||
		origin.Host == "" ||
		origin.User != nil ||
		origin.Path != "" ||
		origin.RawQuery != "" ||
		origin.Fragment != "" {
		return false
	}

	host := strings.TrimSuffix(strings.ToLower(origin.Hostname()), ".")
	if host == "localhost" {
		return true
	}
	ip := net.ParseIP(host)
	return ip != nil && ip.IsLoopback()
}
