#Markov species
A quick experiment with Markov chains, where a dictionary of n-grams is built from a list of latin species names. Using a simple Markov model, new species names are then generated.
This utility is content-independant, and can be used to generate any kind of sequence of words from a dictionary. 

##Utilisation
- build dictionaries from a .csv list of words/sequences of words. `--size` denotes the maximum size of the n-grams to extract. A separate file will be generated for each n-gram size. 

		markov_species build --size=3 path/to/file
		
	Log:

		Generating dictionnary with ngrams of size 2...
		Operation success: true. Dictionnary saved at path Markov Species/export_species_2.txt
		Generating dictionnary with ngrams of size 3...
		Operation success: true. Dictionnary saved at path Markov Species/export_species_3.txt
		
- generate species and print them to the standard output. `--species` denotes the number of sequences to generate, `--words` the number of words in each sequence, and `--seed` the RNG seed (uses rand48 under the hood).

		markov_species generate --species=5 --words=2 --seed=1234 path/to/dictionary
		
	Log:
		
		Generating 5 species names with a length of 2 words.
		Detected ngrams of length 3.
		Seed: 1234
		New species: Oophrysosia Fimbophronster
		New species: Alopteristilor Omelanopora
		New species: Unicansonia Effenella
		New species: Cnemiphlox Glaucensis
		New species: Lutraea Exarmosmilneedwardalerhamala
		
##About me
More info on my website [simonrodriguez.fr](http://simonrodriguez.fr) and my [blog](http://blog.simonrodriguez.fr).