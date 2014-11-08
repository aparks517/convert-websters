#!/usr/bin/perl -w
# 
# 5/28/14 ADP

use HTML::Entities;
use URI::Escape;
use strict;

# settings
my $output_directory = shift || '.';
my $words_directory = shift || '';
my $max_words = shift || 0;

# read
my @entries = do('read.pl');

# build word index and list
# the word index has the words as keys and arrayrefs of entry indices as values
# the word list is a list of all of the words in the order of first entry
my(@word_list, %word_index);
for (my $i = 0; $i < scalar(@entries); $i++){
	# headword
	my $headword = $entries[$i]->{headword};

	# word (lowercased, used as index)
	my $word = lc($headword);

	# if the word is already in the word index, add this entry to the
	# word index.  otherwise, add the word to the word index and word
	# list
	if (defined($word_index{$word})){
		push @{$word_index{$word}}, $i;
	} else {
		$word_index{$word} = [$i];
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

# word list header and list open tag
print "<!-- \@include _wordlist_header -->\n<ul id='wordlist'>\n";

# iterate word list, emitting a file in the output directory for each word 
# and word list links on stdout
for my $word (@word_list){
	# word list entry
	my $uri = $words_directory . "/" .  uri_escape("$word.html");
	my $encoded_word = encode_entities($word);
	print "<li><a href='$uri'>$encoded_word</a></li>\n";

	# open word file
	open WORD, ">$output_directory/$word.html" || die "couldn't open word file";

	# word header
	print WORD "<!-- \$title $encoded_word -->\n<!-- \@include _word_header -->\n";

	# iterate entries
	for my $i (@{$word_index{$word}}){
		# entry 
		my $entry = $entries[$i];

		# entry div open tag
		print WORD "<div class='entry' id='$i'>\n";

  		# headword
		my $headword = encode_entities($entry->{headword});
		print WORD "<h1>$headword</h1>\n";

  		# subhead
		my $subhead;
		for my $key (qw(pronunciation part_of_speech etymology specialty)){
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

# list close tag and word list footer
print "</ul>\n<!-- \@include _wordlist_footer -->\n";
