Instruction are [here](http://www.twitch.tv/problems/spellcheck)

# SpellChecker

Module made of functions that spellcheck given words and correct them.

Work as a prompt, you can type words one by one or pipe a list of words through its input.

SpellChecker uses `/usr/share/dict/words` as the reference dictionary. Feel free to change it:

	SpellChecker.initialize_dictionary('/usr/share/dict/words')

## Complexity

SpellChecker has a complexity at runtime < O(n), where n is the number of words in dictionary, for a given word. This means that for a given word, the spellchecker will not look through all dictionary to find the correcter word.

Here is how:

- Create a new Hash where keys are the alaphabet letters (a -> z) and each values are an empty Array
- For each word in dictionary, push the word to the array where the key of the has is equal to the first letter of the word.

Then it is easy to spellcheck any given words by following these steps:

- Take word first `letter`
- Select from hash the array where key equal `letter`
- If `letter` is a vowel, take all arrays from hash where keys are vowels.
- Return word if word is in selected arrays
- If not, create regex base on word
- Run regex agains selected arrays
- Return if only one result
- If not, run Levenshtein agains all candidates
- Return result

# SpellGenerator

Class that generate misspelled words base on instructions. 100% of generated words can be corrected by SpellChecker.

## Usage

	./spellgenerator [nb_words_to_generate]
	
*nb_words_to_generate is set to 100 by default*

You can pipe its ouput to SpellChecker

	./spellgenerator | ./spellchecker

# Spec

You can run specs for both files by doing:

	rake
	
Made by [Pierre-Louis Gottfrois](http://fr.linkedin.com/in/pierrelouisgottfrois/)