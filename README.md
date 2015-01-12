# cmdi-conversion-checker
Script that takes a hierarchy of IMDI records and a parallel hierarchy of converted CMDI
records and validates the conversion by converting the CMDIs back to IMDI (using the
stylesheets from the [MetadataTranslator](https://github.com/TheLanguageArchive/MetadataTranslator) and comparing the originals with the conversion
output by means of the [ImdiDiff](https://github.com/TheLanguageArchive/ImdiDiff) tool.

Parameters:

1. Location of directory with original IMDIs
2. Location of CMDIs derived from this IMDI (same directory structure assumed)

Usage: `./cmdi-conversion-checker.sh original-imdi-dir converted-cmdi-dir`

**Important**: set the `IMDI_DIFF_JAR` parameter to point to the ImdiDiff jar (with dependencies) in the `cmdi-conversion-checker.sh` source file.
