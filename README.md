# Fraktionen im Deutschen Bundestag 1949–1990
# Examples of experimental conversion of original fractional protocols to TEI documents.

The [sources](https://github.com/DARIAH-SI/fraktionsprotokolle/tree/master/sources) directory
contains original examples of transcripts of protocols in Word DOC file format. 
These documents were provided by the "Kommission für Geschichte des Parlamentarismus und der
politischen Parteien" - [KGPARL](https://kgparl.de/), which manages the project
[Fraktionen im Deutschen Bundestag 1949–1990](https://kgparl.de/).

For further conversions, the original DOC files must first be saved as DOCX files.
Direcotory [docx](https://github.com/DARIAH-SI/fraktionsprotokolle/tree/master/docx)
contains this new DOCX files.

The first conversion from DOC to TEI was made with
[XSL stylesheets for TEI XML](https://tei-c.org/tools/stylesheets/). 
The [OxGarage](https://oxgarage2.tei-c.org/) service could also be used. The conversion results
are in the directory [tei-v1](https://github.com/DARIAH-SI/fraktionsprotokolle/tree/master/tei-v1).

Genuine Word documents contain project-specific Word styles:

- epf_Dok_Nummer and Doknummer: Document number
- epf_Dok_Titel: Document title
- epf_Dok_Kopf and Dokumkopf: Document content metadata
- epf_SVP_Überschrift, Sitzungsverlauf, epf_SVP, epf_SVP_Ende: Meeting agenda
- epf_SVP_Anker: Anchor element - in text start of new agenda item
- epf_Grundtext and Grundtext: Document content in this case, transcripts of speeches

I used the semantic meanings of these styles to further annotate TEI documents.
To that end, I wrote an XSLT stylesheet [KGParl2parlaCLARIN.xsl](https://github.com/DARIAH-SI/fraktionsprotokolle/tree/master/XSLT).
The results of this conversion are in [tei-v2](https://github.com/DARIAH-SI/fraktionsprotokolle/tree/master/tei-v2) directory.

In annotating the speakers, speakers, and namespaces, I also used some of the original Word styles for bold and italics, along with
the semicolon that follows the speaker's name.

When annotating protocols in TEI, I followed the [parla-CLARIN](https://clarin-eric.github.io/parla-clarin/) guidelines.