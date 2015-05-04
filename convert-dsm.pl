#!/usr/bin/perl -w
# 
# 5/22/14 ADP

use HTML::Entities;
use strict;

# configuration
my $unsafe_characters = '<>&"\'';

# read
my @entries = do('read.pl');

# emit xml header and dictionary open tag
print <<'EOF';
<?xml version="1.0" encoding="UTF-8"?>
<d:dictionary xmlns="http://www.w3.org/1999/xhtml" xmlns:d="http://www.apple.com/DTDs/DictionaryService-1.0.rng">
EOF

# iterate entries
for (my $i = 0; $i < scalar(@entries); $i++){
  # entry
  my $entry = $entries[$i];

  # headword
  my $headword = encode_entities($entry->{headword}, $unsafe_characters);
  $headword =~ s/&#39;/&apos;/g;

  # emit entry open tag
  print "<d:entry id='entry$i' d:title='$headword'>\n";

  # emit index tag
  print "<d:index d:value='$headword' d:title='$headword'/>\n";
  
  # emit headword
  print "<h1>$headword</h1>\n";

  # construct subhead
  my $subhead;
  for my $key (qw(pronunciation part_of_speech etymology specialty)){
    my $value = $entry->{$key};
    if (defined($value)){
      $value = encode_entities($value, $unsafe_characters);
      $subhead .= "<span class='$key'>$value</span>\n";
    }
  }

  # emit subhead
  print "<p class='subhead'>\n$subhead</p>" if defined($subhead);

  # emit definition
  for my $line (split("\n", $entry->{definition})){
    $line = encode_entities($line, $unsafe_characters);
    print "<p class='definition'>$line</p>\n";
  }

  # emit close entry tag
  print "</d:entry>\n";
}

# dictionary close tag
print "</d:dictionary>\n";
