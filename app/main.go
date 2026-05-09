package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {
	pod := os.Getenv("POD_NAME")
	node := os.Getenv("NODE_NAME")

	http.HandleFunc("/health", func(w http.ResponseWriter, _ *http.Request) {
		fmt.Fprintln(w, `{"status":"ok"}`)
	})

	http.HandleFunc("/", func(w http.ResponseWriter, _ *http.Request) {
		fmt.Fprintf(w, "<h1>Hello from GKE</h1><p>Pod: %s</p><p>Node: %s</p>", pod, node)
	})

	addr := ":8080"
	log.Printf("listening on %s", addr)
	log.Fatal(http.ListenAndServe(addr, nil))
}
