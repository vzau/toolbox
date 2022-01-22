package main

import (
	"encoding/json"
	"fmt"
	"os"
	"time"

	"github.com/joho/godotenv"
	"github.com/lestrrat-go/jwx/jwa"
	"github.com/lestrrat-go/jwx/jwk"
	"github.com/lestrrat-go/jwx/jwt"
)

func main() {
	godotenv.Load()

	fmt.Printf("ZDV_JWK=%s\n", os.Getenv("ZDV_JWK"))

	keyset, err := jwk.Parse([]byte(os.Getenv("ZDV_JWK")))
	if err != nil {
		fmt.Printf("Couldn't parse JWK: %s\n", err)
		return
	}
	key, _ := keyset.LookupKeyID("ed1")

	token := jwt.New()
	token.Set(jwt.IssuerKey, "auth.kzdv.io")
	token.Set(jwt.AudienceKey, "SSO")
	token.Set(jwt.SubjectKey, "876594")
	token.Set(jwt.IssuedAtKey, time.Now())
	token.Set(jwt.ExpirationKey, time.Now().Add(time.Hour*24*7))

	signed, err := jwt.Sign(token, jwa.EdDSA, key)
	if err != nil {
		fmt.Printf("Couldn't sign key: %s\n", err)
		return
	}

	fmt.Printf("Token = %s\n", signed)

	pubkeyset, err := jwk.PublicSetOf(keyset)
	if err != nil {
		fmt.Printf("Couldn't generate public set: %s\n", err)
		return
	}
	pubkeyjs, err := json.Marshal(pubkeyset)
	if err != nil {
		fmt.Printf("Couldn't marshal pubkeyset: %s\n", err)
		return
	}
	fmt.Printf("Pub Key = %s", string(pubkeyjs))
	fmt.Printf("ExpiresIn=%d", (time.Hour*24*7)/time.Second)
}
