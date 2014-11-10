#!/usr/bin/perl -w
# 
# 5/28/14 ADP

use HTML::Entities;
use URI::Escape;
use strict;

# settings
my $output_directory = shift || '.';
my $max_words = shift || 0;

# read
my @entries = do('read.pl');

# build word list and entry index
# the word list is a list of all of the (unique) words in the order of first entry
# the entry index has the words as keys and arrayrefs of entry indices as values
my(@word_list, %entry_index);
for (my $i = 0; $i < scalar(@entries); $i++){
	# headword
	my $headword = $entries[$i]->{headword};

	# word (lowercased, used as index)
	my $word = lc($headword);

	# if the word is already in the entry index, add this entry to the
	# entry index.  otherwise, add the word to the entry index and word
	# list
	if (defined($entry_index{$word})){
		push @{$entry_index{$word}}, $i;
	} else {
		$entry_index{$word} = [$i];
		push @word_list, $word;
	}
}
warn "Indexed " . scalar(@word_list) . " words\n";

# remove random words (for testing)
if ($max_words){
	my $words_to_remove = scalar(@word_list) - $max_words;
	for (my $i=0; $i < $words_to_remove; $i++){
		splice @word_list, rand(scalar(@word_list)), 1;
	}
	warn "Elimited all but " . scalar(@word_list) . " words\n";
}

# produce quick index, which is a hash with the first two letters of words
# as keys and arrayrefs of words as values
my %quick_index;
for my $word (@word_list){
	# first two letters of word
	my $first_two = substr($word, 0, 2);

	# if there is already a quick index key for the first two letters of this
	# word, add the word to that arrayref.  otherwise, add the key.
	if (defined($quick_index{$first_two})){
		push @{$quick_index{$first_two}}, $word;
	} else {
		$quick_index{$first_two} = [$word];
	}
}

# index directory; create if doesn't exist
my $index_directory = "$output_directory/indices";
unless (-d $index_directory){
	mkdir $index_directory || die "couldn't create index directory";
	warn "Created index directory $index_directory\n";
}

# open meta index file (index of quick indices) and list tag
open META, ">$index_directory/meta.html" || die "couldn't open meta index file";
print META "<!-- \@include _index_header -->\n<ul>\n";

# emit quick index files
for my $first_two (sort(keys(%quick_index))){
	# meta index link
	my $uri = uri_escape("$first_two.html");
	my $encoded_first_two = encode_entities($first_two);
	my $word_count = scalar(@{$quick_index{$first_two}});
	print META "<li>$word_count words beginning with <a href='$uri'>$encoded_first_two</a></li>\n";

	# open file and open word list tag
	open INDEX, ">$index_directory/$first_two.html" || die "couldn't open quick index file";
	print INDEX "<!-- \@include _index_header -->\n<ul id='word-list'>\n";

	# words
	for my $word (@{$quick_index{$first_two}}){
		my $uri = "../words/" . uri_escape("$word.html");
		my $encoded_word = encode_entities($word);
		print INDEX "<li><a href='$uri'>$encoded_word</a></li>\n";
	}

	# close word list tag and file
	print INDEX "</ul>\n<!-- \@include _index_footer -->\n";
	close INDEX;
}

# close meta index list tag and file
print META "</ul>\n<!-- \@include _index_footer -->\n";
close META;

# words directory; create if doesn't exist
my $words_directory = "$output_directory/words";
unless (-d $words_directory){
	mkdir $words_directory || die "couldn't create words directory";
	warn "Created words directory $words_directory\n";
}

# iterate word list, emitting a file in the output directory for each word 
# and word list links on stdout
for my $word (@word_list){
	# open word file
	open WORD, ">$words_directory/$word.html" || die "couldn't open word file";

	# word header
	my $encoded_word = encode_entities($word);
	print WORD "<!-- \$title $encoded_word -->\n<!-- \@include _word_header -->\n";

	# iterate entries
	for my $i (@{$entry_index{$word}}){
		# entry 
		my $entry = $entries[$i];

		# entry div open tag
		print WORD "<div class='entry' id='$i'>\n";

  		# headword
		my $headword = encode_entities($entry->{headword});
		print WORD "<h1>$headword</h1>\n";

  		# subhead
		my $subhead;
		for my $key (qw(pronunciation part-of-speech etymology specialty)){
			my $value = $entry->{$key};
			if (defined($value)){
				$value = encode_entities($value);
				$subhead .= "<span class='$key'>$value</span>\n";
			}
		}
		print WORD "<p class='subhead'>\n$subhead</p>" if defined($subhead);
	
		# definition
		for my $line (split("\n", $entry->{definition})){
			$line = encode_entities($line);
			print WORD "<p class='definition'>$line</p>\n";
		}

		# entry div close tag
		print WORD "</div>\n";
	} # iterate entries
	
	# word footer
	print WORD "<!-- \@include _word_footer -->\n";

	# close word file
	close WORD;
} # iterate words