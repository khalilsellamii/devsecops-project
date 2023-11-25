package db

type DBInterface interface {
	AuthenticateUser(username, password string) (bool, error)
	// Add other methods for database interactions if needed
}
