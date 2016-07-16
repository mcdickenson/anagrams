package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"sort"
	"strconv"
	"strings"
	"sync"

	"github.com/julienschmidt/httprouter"
)

// Track anagrams
var (
	_anagramsMu sync.RWMutex
	_anagrams   = make(map[string]map[string]struct{})
)

// add a type for sorting a slice of runes
type RuneSlice []rune

func (p RuneSlice) Len() int           { return len(p) }
func (p RuneSlice) Less(i, j int) bool { return p[i] < p[j] }
func (p RuneSlice) Swap(i, j int)      { p[i], p[j] = p[j], p[i] }

func main() {
	router := httprouter.New()
	// Adding words to anagram list
	router.POST("/words.json", addWords)

	// Getting anagrams for a word
	router.GET("/anagrams/:word", getAnagrams)

	// Deleting all words
	router.DELETE("/words.json", deleteAllWords)

	// Deleting anagrams for a specific word
	router.DELETE("/words/:word", deleteWord)

	log.Fatal(http.ListenAndServe(":3000", router))
}

func keyFromWord(w string) string {
	// sort characters in string
	// so that anagrams map to the same key
	chars := []rune(w)
	sort.Sort(RuneSlice(chars))
	key := string(chars)
	return key
}

func wordFromParams(ps httprouter.Params) string {
	word := ps.ByName("word")
	word = strings.Split(word, ".")[0]
	return word
}

func addWords(w http.ResponseWriter, r *http.Request, _ httprouter.Params) {
	_anagramsMu.Lock()
	defer _anagramsMu.Unlock()

	// Read in the request body
	body, err := ioutil.ReadAll(r.Body)

	// Parse JSON into map
	objmap := map[string][]string{}
	err = json.Unmarshal(body, &objmap)

	if err != nil {
		http.Error(w, http.StatusText(http.StatusBadRequest), http.StatusBadRequest)
	}

	// Add words to the anagram list
	words := objmap["words"]
	for _, w := range words {
		key := keyFromWord(w)
		if _anagrams[key] == nil {
			_anagrams[key] = map[string]struct{}{w: struct{}{}}
		} else {
			_anagrams[key][w] = struct{}{}
		}
	}

	w.WriteHeader(http.StatusCreated)
}

func getAnagrams(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
	_anagramsMu.RLock()
	defer _anagramsMu.RUnlock()

	word := wordFromParams(ps)

	w.WriteHeader(http.StatusOK)
	hsh := map[string][]string{}
	vals := _anagrams[keyFromWord(word)]

	// Optional param to limit the number of results
	limit := len(vals)
	limitParam := r.URL.Query().Get("limit")
	if limitParam != "" {
		limit, _ = strconv.Atoi(limitParam)
	}

	hsh["anagrams"] = make([]string, 0, len(vals))
	for v := range vals {
		// don't include the word itself in the response
		if v != word && len(hsh["anagrams"]) < limit {
			hsh["anagrams"] = append(hsh["anagrams"], v)
		}
	}

	body, _ := json.Marshal(hsh)
	fmt.Fprint(w, string(body))
}

func deleteAllWords(w http.ResponseWriter, r *http.Request, _ httprouter.Params) {
	_anagramsMu.Lock()
	defer _anagramsMu.Unlock()

	_anagrams = make(map[string]map[string]struct{})
	w.WriteHeader(http.StatusNoContent)
}

func deleteWord(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
	_anagramsMu.Lock()
	defer _anagramsMu.Unlock()

	word := wordFromParams(ps)

	delete(_anagrams[keyFromWord(word)], word)
}
