package algorithms

type Shortener interface {
	Generate(input string) (string, error)
}