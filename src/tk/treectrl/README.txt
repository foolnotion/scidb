This is not the original treectrl. This version is modified
by Gregor Cramer for the use in Scidb.

It has a modified (and fixed) column layout algorithm, a few
bug fixes, new options:

	treectrl <pathName> -class <string>
		Sets the class name (cannot be used with 'configure').

	treectrl <pathName> -fullstripes <boolean>
		If set, the whole area will be filled with stripes.
		Defaults to "no".

	treectrl <pathName> -keepuserwidth <boolean>
		If set, keeps the width of a column resized by user.
		If not set, the column width may change if the treectrl
		has resized. Defaults to "yes".
	
	treectrl <pathName> -expensivespanwidth <boolean>
	   If set, use expensive calculation considering column
		spans. If not set, column spans will be discarded
		during the calculation. Defaults to "no".

	treectrl <pathName> -state normal|disabled
		Set one of the states for the treectrl. If set to
		state normal the item/columns state will not be
		superseeded, but if set to disabled the item/column
		state will be superseeded. Defaults to "normal".

	treectrl <pathName> -canvaspadx <pixels>
		Specifies the width of extra whitespace on the left and
		right edges of the canvas.
		
	treectrl <pathName> -canvaspadx <pixels>
		Specifies the width of extra whitespace on the top and
		bottom edges of the canvas.
		
	<pathName> column create <columnDesc> -steady <boolean>
		If set, keeps the width of a column after an element
		of the column has changed (scrolling will be
		significantly faster). Defaults to "no".

	<pathName> element configure <elem-id> \
				-specialfont <font> ?<first> <last>?
		Sets a second font that wil be used for any unicode
		point >= 256. Optional a range may given, in this case
		this font will only be used for characters inside this
		range (inclusive the border values).

and new commands:

	<pathName> headerheight
		Returns the used height of the column header.

	<pathName> column ellipsis <columnDesc>
		Returns whether the text in column header ends with an
		ellipsis because it does not fit.

	<pathName> column minimumwidth <columnDesc>
		Returns the minimum with of the column. It is zero if
		the column is not visible. This command is useful for
		calculating the minimum width of the whole treectrl
		widget.
	
	<pathName> column expand <columnDesc> ?<visible-space-flag>?
		Expand the given column until the tree width (or visible
		width) will be reached.

	<pathName> column optimize ?<list-of-columnDesc>?
		Fit all specified columns to the needed column width
		(excluding the needed width for the header). The list may
		be empty. Assume all columns if no list is given.

	<pathName> column fit ?<list-of-columnDesc>?
		Fit all specified columns to the needed column width
		(excluding the needed width for the header), but do not
		shrink the columns. The list may be empty. Assume all
		columns if no list is given.

	<pathName> column squeeze ?<list-of-columnDesc>?
		Squeeze all specified columns until all columns will fit
		the visible width (excluding the needed width for the
		header). The list may be empty. Assume all columns if no
		list is given.

"pathName item sort itemDesc ?option ...?" has new option:

	-nocase
		Causes comparisons to be handled in a case-insensitive manner.
		Has no effect if combined with the -dictionary, -integer, or
		-real options.

==================================================================
Original content of README.txt:
------------------------------------------------------------------
Current maintainer: Tim Baker (treectrl@users.sourceforge.net)
Website: http://tktreectrl.sourceforge.net/

An extra help document with examples and pictures is available from
the main website:
http://tktreectrl.sourceforge.net/Understanding%20TkTreeCtrl.html
