/**
 * Author: mrchnk
 * Time: 17.10.13 12:17
 */
package com.sig.utils {

	public class Sort {

		static private const BUFFER : Vector.<Object> = new Vector.<Object>();

		/**
		 * Fast memory-friendly sorting of vector elements
		 */
		static public function mergeSort( input : Vector.<*>, compareFunc : Function, buffer : Vector.<*> = null ) : void {
			if ( !buffer ) {
				buffer = BUFFER as Vector.<*>;
			}
			var length : int = buffer.length = input.length;
			mergeSortPart( input, buffer, compareFunc, 0, length )
		}

		static public function mergeSortPart( input : Vector.<*>, buffer : Vector.<*>, compareFunc : Function, startIndex : int = 0, length : int = 0 ) : void {
			// This is a port of the C++ merge sort algorithm shown here:
			// http://www.cprogramming.com/tutorial/computersciencetheory/mergesort.html
			if ( length <= 1 ) {
				return;
			}
			else {
				var i : int = 0;
				var endIndex : int = startIndex + length;
				var halfLength : int = length / 2;
				var l : int = startIndex;              // current position in the left subvector
				var r : int = startIndex + halfLength; // current position in the right subvector

				// sort each subvector
				mergeSortPart( input, buffer, compareFunc, startIndex, halfLength );
				mergeSortPart( input, buffer, compareFunc, startIndex + halfLength, length - halfLength );

				// merge the vectors, using the buffer vector for temporary storage
				for ( i = 0; i < length; i++ ) {
					// Check to see if any elements remain in the left vector;
					// if so, we check if there are any elements left in the right vector;
					// if so, we compare them. Otherwise, we know that the merge must
					// take the element from the left vector. */
					if ( l < startIndex + halfLength &&
						(r == endIndex || compareFunc( input[l], input[r] ) <= 0) ) {
						buffer[i] = input[l];
						l++;
					}
					else {
						buffer[i] = input[r];
						r++;
					}
				}

				// copy the sorted subvector back to the input
				for ( i = startIndex; i < endIndex; i++ ) {
					input[i] = buffer[int( i - startIndex )];
				}
			}
		}

	}

}
