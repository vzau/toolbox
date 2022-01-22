package main

import (
	"fmt"
	"os"
	"strconv"

	gonanoid "github.com/matoous/go-nanoid/v2"
)

func main() {
	genlen, err := strconv.ParseInt(os.Args[1], 10, 32)
	if genlen == 0 {
		genlen = 21
	}
	if err != nil {
		genlen = 21
	}

	id, err := gonanoid.Generate("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789", int(genlen))
	if err != nil {
		fmt.Println("Error generating random string " + err.Error())
	}

	fmt.Print(id)
}
