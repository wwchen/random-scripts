/*
 * Wordmixer
 * June 24, 2010
 * William Chen
 *
 * Reads in a file and changes the order of letters within a word,
 * except for the beginning and ending character. Outputs to out.txt
 */

#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <fstream>
#include <time.h>
#include <string.h>

using namespace std;

int main( int argc, char** argv )
{
	char* filename = (char *) "output.txt";

	if( argc < 2 ) {
		printf( "Usage: %s inputfile.txt [options]\n", argv[0] );
		printf( "\nOptions:\n" );
		printf( "   -o\toutput file name\n");
		exit(1);
	}

	else if( argc > 2 ) {
		if( strcmp(argv[2], "-o")==0 ) {
			filename = argv[3];
		}
		else {
			printf( "Invalid option.\n" );
			exit(1);
		}
	}

	srand( time(NULL) );
	ifstream infile;
	ofstream outfile( filename );
	infile.open( argv[1] );

	if( !infile.good() ) {
		printf( "Bad input filename: %s\n", argv[1] );
	}

	while( !infile.eof() ) {
		string word;
		infile >> word;
		
		int len = word.length();
		
		if( len <= 3 ) {
			outfile << word << ' ';
			continue;
		}
		for( int k=1; k<len-2; k++ ) {
			int random;
			if( k < len-3 )
				random = rand() % (len-k-2) + k;
			else if( k == len-3 )
				random = k+1;

			char old = word[k];
			word[k] = word[random];
			word[random] = old;
		}

		outfile << word << ' ';
	}

	infile.close();
	outfile.close();

	return 0;
}
