echo "<html lang='`basename \`pwd\``'> $1" | ../hyphenate | sed 's/&shy;/-/g' | cut -b18-
