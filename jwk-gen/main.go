package main

import (
	"crypto/ecdsa"
	"crypto/ed25519"
	"crypto/elliptic"
	"crypto/rand"
	"crypto/rsa"
	"encoding/json"
	"fmt"

	"github.com/lestrrat-go/jwx/jwk"
)

func main() {
	pub, priv, err := ed25519.GenerateKey(rand.Reader)
	if err != nil {
		fmt.Printf("Failed to generate key: %s\n", err)
		return
	}

	key, err := jwk.New(priv)
	key2, _ := jwk.New(pub)

	buf, _ := json.Marshal(key)
	buf2, _ := json.Marshal(key2)
	fmt.Println(string(buf))
	fmt.Println(string(buf2))

	ecraw, _ := ecdsa.GenerateKey(elliptic.P384(), rand.Reader)
	eckey, _ := jwk.New(ecraw)
	eckey.Set(jwk.KeyIDKey, 2)
	ecbuf, _ := json.Marshal(eckey)
	fmt.Println(string(ecbuf))

	rsaraw, _ := rsa.GenerateKey(rand.Reader, 2048)
	rsakey, _ := jwk.New(rsaraw)

	keyset := jwk.NewSet()
	keyset.Add(eckey)
	keyset.Add(key)
	keyset.Add(rsakey)

	ks, _ := json.Marshal(keyset)
	fmt.Println(string(ks))
}
