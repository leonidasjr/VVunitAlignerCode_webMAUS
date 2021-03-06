# VVunitAligner.psc #################################################
# Script implemented by Leônidas Silva Jr. (leonidas.silvajr@gmail.com), CH/UEPB, Brazil,
# based originally on Florian Schiel's webMAUS aligner
####--------------------- CITATION ---------------------#####
### KISLER, Thomas, REICHEL, Uwe D., SCHIEL Florian (2017). Multilingual processing of speech via web services. 
### Computer Speech & Language, v. 45, p. 326–347. 
#-#-#-#-#-#-#-#-#-#-#-#-#- C R E D I T S -#-#-#-#-#-#-#-#-#-#-#-#-#
# Florian Schiel, for the tips about his own webMAUS aligner, and technical suggestions
#	for post-processing on vowelonset units
# Plinio Barbosa, for the whole teaching and supervision during my postdoctoral research besides
#	the crucial tips/suggestions on programming in Praat as well as being a great friend
# Copyright (C) 2021, 2022 Silva Jr., Leônidas

#####----------------------- HOW TO CITE -----------------------###### 
## SILVA JR., L. (2022). VVUnitAligner. Computer program for Praat (version 0.5).
######################################################################

## Getting started...

form Phonetic syllable alignment
	word Folder Paste directory path
	comment WARNING! This script must be in the same folder of the sound file
	comment ".TextGrid" files must be must be created from webMAUS ("PIPELINE without ASR")
	comment URL: https://clarin.phonetik.uni-muenchen.de/BASWebServices/interface/Pipeline
	choice Language: 2
  		button Portuguese (BR)
  		button English (US)
		button French (FR)
		button Spanish (ES)
	positive Threshold_(dB) 50
	boolean Chunk_segmentation 0
	comment Complete the following target-word blanks to chunk the speech
	word Chunk_starting_word_1
	word Chunk_starting_word_2
	word Chunk_starting_word_3
	word Chunk_starting_word_4
	word Chunk_end_word
	boolean Save_TextGrid_files 0
	#natural Tier_number_1 3
	#natural Tier_number_2 1
	#real Max_period 0.02
	#real Mean_period 0.01
endform

## cleaning Praat's objects window before workflow
numberOfSelectedObjects = numberOfSelected()
if numberOfSelectedObjects > 0
	select all
	Remove
endif
clearinfo

Create Strings as file list... audioDataList *.wav
numberOfFiles = Get number of strings
writeInfoLine: "DATA SUMMARY"
appendInfoLine: ""

for y from 1 to numberOfFiles
	select Strings audioDataList
	soundname$ = Get string... y
	Read from file... 'soundname$'
	sound_file$ = selected$ ("Sound")
	tg$ = sound_file$ + ".TextGrid"

	## this is MAUS original TextGrid file
	maus$ =  "MAUS" + mid$(sound_file$,7,3)
	Read from file... 'tg$'
	select TextGrid 'sound_file$'
	Copy... 'sound_file$'
	Rename... 'maus$'

	## setting a ".TextGrid" name for MAUS segmentation (G2P->MAUS->PHO2SYL) into phonological syllables
	mausMasVV$ = "MAUS-MAS-VV" + mid$(sound_file$,7,3)
	
	select TextGrid 'sound_file$'
	repeat
		ntiers = Get number of tiers
		t = 1
		select TextGrid 'sound_file$'
		Remove tier: 't'
		ntiers = Get number of tiers
	until ntiers = 2
	
	Duplicate tier: 2, 2, "PhonoSyl"
	Duplicate tier: 1, 1, "VC"
	textPhonoSyl = Get number of intervals: 3
	textVC = Get number of intervals: 1
	
	## Labeling the phonological syllables tier (from webMAUS) as "PhonoSyl" 
	for i from 2 to textPhonoSyl - 1
		label$ = Get label of interval: 3, 'i'
		if label$ = "<p:>" or label$ = "<p>"
    			Set interval text: 3, 'i', "#"
		else
    			Set interval text: 3, 'i', "PhonoSyl"
  		endif
	endfor

	## Different languages require distinct procedures to be forced aligned and labeled
	
	## for Spanish (ES)
	if language = 4
		@lang_SP
	endif
	## for French
	if language = 3
		@lang_FR
	endif
	## for American English
	if language = 2
		@lang_AmE
	endif
	## for Brazilian Portuguese
	if language = 1
		@lang_BP
	endif
	
	## V/C/# labelling - procedures for each language
	#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####
	## for American English
	procedure lang_AmE
		for i from 2 to textVC - 1
			label$ = Get label of interval: 1, 'i'
			if label$ = "u:" or label$ = "O:" or label$ = "o~" or label$ = "i:" or label$ = "e~" or label$ = "A:" or label$ = "a~"
			... or label$ = "3:" or label$ = "3`" or label$ = "V" or label$ = "U" or label$ = "u"
			... or label$ = "Q" or label$ = "I" or label$ = "E" or label$ = "e" or label$ = "6" or label$ = "@" or label$ = "{" 
			... or label$ = "U@" or label$ = "@U" or label$ = "OI" or label$ = "I@"
			... or label$ = "eI" or label$ = "e@" or label$ = "aU" or label$ = "aI" or label$ = "oI" or label$ = "uI"
				Set interval text: 1, 'i', "V"
			elsif label$ = "tS" or label$ = "N=" or label$ = "n=" or label$ = "m=" or label$ = "l=" or label$ = "h\"
			... or label$ = "h\" or label$ = "dZ" or label$ = "Z" or label$ = "z" or label$ = "w" or label$ = "v" or label$ = "T" 
			... or label$ = "t" or label$ = "S" or label$ = "s" or label$ = "R" or label$ = "r" or label$ = "P" or label$ = "N"
			... or label$ = "n" or label$ = "m" or label$ = "l" or label$ = "k" or label$ = "j" or label$ = "h" or label$ = "p"
			... or label$ = "g" or label$ = "f" or label$ = "D" or label$ = "d" or label$ = "b" or label$ = "4" 
				Set interval text: 1, 'i', "C"
			elsif label$ = "<p:>" or label$ = "<p>"
				Set interval text: 1, 'i', "#"
			elsif label$ = "?"
				Set interval text: 1, 'i', ""
			endif
		endfor
	endproc
	#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####
	## for Brazilian Portuguese
	procedure lang_BP
		for i from 2 to textVC - 1
			label$ = Get label of interval: 1, 'i'
			if label$ = "i" or label$ = "e" or label$ = "eh" or label$ = "a" or label$ = "oh" or label$ = "o" or label$ = "u"
			... or label$ = "iN" or label$ = "eN" or label$ = "aN" or label$ = "oN" or label$ = "uN"
			... or label$ = "I" or label$ = "E" or label$ = "A" or label$ = "O" or label$ = "U" or label$ = "w"
			... or label$ = "IN" or label$ = "EN" or label$ = "AN" or label$ = "ON" or label$ = "UN"
			... or label$ = "eI" or label$ = "ehI" or label$ = "aI" or label$ = "ohI" or label$ = "oI" or label$ = "uI" 
			... or label$ = "aNI" or label$ = "oNI" or label$ = "iU" or label$ = "eU" or label$ = "ehU" or label$ = "aU" 
			... or label$ = "ohU" or label$ = "oU" or label$ = "aNU" or label$ = "IU" or label$ = "UU" or label$ = "II" 
			... or label$ = "UI" or label$ = "IA" or label$ = "UA" or label$ = "ANU"
				Set interval text: 1, 'i', "V"
			elsif label$ = "p" or label$ = "t" or label$ = "k" or label$ = "b" or label$ = "d" or label$ = "g"
			... or label$ = "f" or label$ = "s" or label$ = "sh" or label$ = "v" or label$ = "z" or label$ = "zh" or label$ = "S" 
			... or label$ = "ss" or label$ = "SS" or label$ = "ts" or label$ = "TS" or label$ = "tts" or label$ = "dz" or label$ = "j"
			... or label$ = "dZ" or label$ = "m" or label$ = "n" or label$ = "nh" or label$ = "r" or label$ = "rr" 
			... or label$ = "R" or label$ = "l" or label$ = "lh" or label$ = "L" or label$ = "tS" or label$ = "N"
			... or label$ = "ddz"
				Set interval text: 1, 'i', "C"
			elsif label$ = "<p:>"
				Set interval text: 1, 'i', "#"
			elsif label$ = "?"
				Set interval text: 1, 'i', ""
			endif
		endfor
	endproc
	#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####
	## for French
	procedure lang_FR
		for i from 2 to textVC - 1
			label$ = Get label of interval: 1, 'i'
			if label$ = "o~" or label$ = "e~" or label$ = "a~" or label$ = "9~"
			... or label$ = "y" or label$ = "O" or label$ = "o" or label$ = "i" or label$ = "I"
			... or label$ = "e" or label$ = "E" or label$ = "A" or label$ = "a" or label$ = "9" 
			... or label$ = "2" or label$ = "@" or label$ = "u"
				Set interval text: 1, 'i', "V"
			elsif label$ = "Z" or label$ = "z" or label$ = "w" or label$ = "T" or label$ = "t"
			... or label$ = "S" or label$ = "s" or label$ = "R" or label$ = "r" or label$ = "p" or label$ = "N"
			... or label$ = "n" or label$ = "m" or label$ = "l" or label$ = "k" or label$ = "J" or label$ = "j"
			... or label$ = "H" or label$ = "g" or label$ = "f" or label$ = "b" or label$ = "B" or label$ = "d"
			... or label$ = "D" or label$ = "v" or label$ = "V"
				Set interval text: 1, 'i', "C"
			elsif label$ = "<p:>" or label$ = "<p>"
				Set interval text: 1, 'i', "#"
			elsif label$ = "?"
				Set interval text: 1, 'i', ""
			endif
		endfor
	endproc
	#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####
	## for Spanish
	procedure lang_SP
		for i from 2 to textVC - 1
			label$ = Get label of interval: 1, 'i'
			if label$ = "y:" or label$ = "@u" or label$ = "OI" or label$ = "o~" or label$ = "eU" or label$ = "eI" or label$ = "E~"
			... or label$ = "e~" or label$ = "aU" or label$ = "aI" or label$ = "a~" or label$ = "2:"
			... or label$ = "Y" or label$ = "u" or label$ = "o" or label$ = "i" or label$ = "E" or label$ = "e"
			... or label$ = "a" or label$ = "9" or label$ = "@"
				Set interval text: 1, 'i', "V"
			elsif label$ = "t_h" or label$ = "p_h" or label$ = "tt" or label$ = "tS" or label$ = "rr" or label$ = "pp"
			... or label$ = "kk" or label$ = "jj" or label$ = "dZ" or label$ = "z" or label$ = "x" or label$ = "w" or label$ = "v" 
			... or label$ = "v" or label$ = "T" or label$ = "t" or label$ = "S" or label$ = "s" or label$ = "r" or label$ = "p"
			... or label$ = "N" or label$ = "n" or label$ = "m" or label$ = "L" or label$ = "l" or label$ = "J" 
			... or label$ = "j" or label$ = "h" or label$ = "G" or label$ = "g" or label$ = "F" or label$ = "f"
			... or label$ = "D" or label$ = "d" or label$ = "B" or label$ = "b" or label$ = "K" or label$ = "k"
				Set interval text: 1, 'i', "C"
			elsif label$ = "<p:>" or label$ = "<p>"
				Set interval text: 1, 'i', "#"
			elsif label$ = "?"
				Set interval text: 1, 'i', ""
			endif
		endfor
	endproc
	#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####
	## Delete right boundaries of empty intervals to align vocalic laryngealization
	select TextGrid 'sound_file$'
	j = 2
	repeat
  		n_int = Get number of intervals... 1
			lab$ = Get label of interval: 1, 'j'
			select TextGrid 'sound_file$'
				if lab$ = ""
					Remove right boundary... 1 'j'
				endif
			j = j + 1
			n_int = Get number of intervals... 1
	until j > n_int
	
	## Getting phonetic syllables (V.onset to V.onset, henceforth, VV)
	## Force aligning phonetic syllable (VV) tier from vowel/consonant/pause (V/C/#) tier
	select TextGrid 'sound_file$'
	Get starting points: 1, "is equal to", "V"
	select PointProcess 'sound_file$'_V
	To TextGrid (vuv): 5e-6, 1.25e-6
	#(To TextGrid (vuv): 0.02, 0.01)
	#(To TextGrid (vuv): 'max_period', 'mean_period') (form)
	
	## Alignment correction of the VV tier
	select TextGrid 'sound_file$'_V
	k = 2
	repeat
 		nintervals = Get number of intervals: 1
 		select TextGrid 'sound_file$'_V
		Remove left boundary... 1 'k'
		k = k + 1
		nintervals = Get number of intervals... 1
	until k > nintervals

	nintervals = Get number of intervals: 1
	textVV = Get number of intervals: 1

	## Labelling phonetic syllable as "VV"
	for i from 2 to textVV - 1
		Set interval text: 1, 'i', "VV"
	endfor

	## Merging the ".TextGrid" files: (MAUS + VV)
	select TextGrid 'sound_file$'
		plus TextGrid 'sound_file$'_V
	Merge
	
	## Create a new (MAS-VV) tier that overlaps VV-unit tier
	Duplicate tier: 2, 6, "MAS-VV"
	selectObject: "TextGrid merged"
	
	## Delete the first interval of the new MAS-VV tier whether it is a consonant in the VV tier 
	## Overlapping...

	if language = 3
		@erase1stVVinterval_lang_FR
	elsif language = 2
		@erase1stMASVVinterval_lang_AmE
	elsif language = 1
		@erase1stMASVVinterval_lang_BP
	endif
	
	#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####
	#a = 2
	procedure erase1stMASVVinterval_lang_AmE
		repeat
			labPhone$ = Get label of interval: 6, 2 
				if labPhone$ = "tS" or labPhone$ = "N=" or labPhone$ = "n=" or labPhone$ = "m=" or labPhone$ = "l=" or labPhone$ = "h\"
			... or labPhone$ = "h\" or labPhone$ = "dZ" or labPhone$ = "Z" or labPhone$ = "z" or labPhone$ = "w" or labPhone$ = "v" or labPhone$ = "T" 
			... or labPhone$ = "t" or labPhone$ = "S" or labPhone$ = "s" or labPhone$ = "R" or labPhone$ = "r" or labPhone$ = "P" or labPhone$ = "N"
			... or labPhone$ = "n" or labPhone$ = "m" or labPhone$ = "l" or labPhone$ = "k" or labPhone$ = "j" or labPhone$ = "h" or labPhone$ = "p"
			... or labPhone$ = "g" or labPhone$ = "f" or labPhone$ = "D" or labPhone$ = "d" or labPhone$ = "b" or labPhone$ = "4"
					Remove left boundary: 6, 2
				endif
			labPhone$ = Get label of interval: 6, 2 
		until labPhone$ = "u:" or labPhone$ = "O:" or labPhone$ = "o~" or labPhone$ = "i:" or labPhone$ = "e~" or labPhone$ = "A:" or labPhone$ = "a~"
		... or labPhone$ = "3:" or labPhone$ = "3`" or labPhone$ = "V" or labPhone$ = "U" or labPhone$ = "u"
		... or labPhone$ = "Q" or labPhone$ = "I" or labPhone$ = "E" or labPhone$ = "e" or labPhone$ = "6" or labPhone$ = "@" or labPhone$ = "{" 
		... or labPhone$ = "U@" or labPhone$ = "@U" or labPhone$ = "OI" or labPhone$ = "I@"
		... or labPhone$ = "eI" or labPhone$ = "e@" or labPhone$ = "aU" or labPhone$ = "aI" or labPhone$ = "oI" or labPhone$ = "uI"
	endproc
	#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####
	#b = 2
	procedure erase1stMASVVinterval_lang_BP
		repeat
			labPhone$ = Get label of interval: 6, 2
				if 	labPhone$ = "p" or labPhone$ = "t" or labPhone$ = "k" or labPhone$ = "b" or labPhone$ = "d" or labPhone$ = "g"
			... or labPhone$ = "f" or labPhone$ = "s" or labPhone$ = "sh" or labPhone$ = "v" or labPhone$ = "z" or labPhone$ = "zh" or labPhone$ = "S" 
			... or labPhone$ = "ss" or labPhone$ = "SS" or labPhone$ = "ts" or labPhone$ = "TS" or labPhone$ = "tts" or labPhone$ = "dz" or labPhone$ = "j"
			... or labPhone$ = "dZ" or labPhone$ = "m" or labPhone$ = "n" or labPhone$ = "nh" or labPhone$ = "r" or labPhone$ = "rr" 
			... or labPhone$ = "R" or labPhone$ = "l" or labPhone$ = "lh" or labPhone$ = "L" or labPhone$ = "tS" or labPhone$ = "N"
			... or labPhone$ = "ddz"
					Remove left boundary: 6, 2
				endif
			labPhone$ = Get label of interval: 6, 2
		until labPhone$ = "i" or labPhone$ = "e" or labPhone$ = "eh" or labPhone$ = "a" or labPhone$ = "oh" or labPhone$ = "o" or labPhone$ = "u"
		... or labPhone$ = "iN" or labPhone$ = "eN" or labPhone$ = "aN" or labPhone$ = "oN" or labPhone$ = "uN"
		... or labPhone$ = "I" or labPhone$ = "E" or labPhone$ = "A" or labPhone$ = "O" or labPhone$ = "U" or labPhone$ = "w"
		... or labPhone$ = "IN" or labPhone$ = "EN" or labPhone$ = "AN" or labPhone$ = "ON" or labPhone$ = "UN"
		... or labPhone$ = "eI" or labPhone$ = "ehI" or labPhone$ = "aI" or labPhone$ = "ohI" or labPhone$ = "oI" or labPhone$ = "uI" 
		... or labPhone$ = "aNI" or labPhone$ = "oNI" or labPhone$ = "iU" or labPhone$ = "eU" or labPhone$ = "ehU" or labPhone$ = "aU" 
		... or labPhone$ = "ohU" or labPhone$ = "oU" or labPhone$ = "aNU" or labPhone$ = "IU" or labPhone$ = "UU" or labPhone$ = "II" 
		... or labPhone$ = "UI" or labPhone$ = "IA" or labPhone$ = "UA" or labPhone$ = "ANU"
	endproc
	#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####
	#c = 2
	procedure erase1stMASVVinterval_lang_FR
		repeat
			labPhone$ = Get label of interval: 6, 2
				if labPhone$ = "Z" or labPhone$ = "z" or labPhone$ = "w" or labPhone$ = "T" or labPhone$ = "t"
			... or labPhone$ = "S" or labPhone$ = "s" or labPhone$ = "R" or labPhone$ = "r" or labPhone$ = "p" or labPhone$ = "N"
			... or labPhone$ = "n" or labPhone$ = "m" or labPhone$ = "l" or labPhone$ = "k" or labPhone$ = "J" or labPhone$ = "j"
			... or labPhone$ = "H" or labPhone$ = "g" or labPhone$ = "f" or labPhone$ = "b" or labPhone$ = "B" or labPhone$ = "d"
			... or labPhone$ = "D" or labPhone$ = "v" or labPhone$ = "V"
					Remove left boundary: 6, 2
				endif
				labPhone$ = Get label of interval: 6, 2 
		until labPhone$ = "o~" or labPhone$ = "e~" or labPhone$ = "a~" or labPhone$ = "9~"
			... or labPhone$ = "y" or labPhone$ = "O" or labPhone$ = "o" or labPhone$ = "i" or labPhone$ = "I"
			... or labPhone$ = "e" or labPhone$ = "E" or labPhone$ = "A" or labPhone$ = "a" or labPhone$ = "9" 
			... or labPhone$ = "2" or labPhone$ = "@" or labPhone$ = "u"
	endproc
	#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####-----#####
	## Overlapping VV and MAS-VV tiers
	selectObject: "TextGrid merged"
	a = 2
	repeat
		n_intVV = Get number of intervals... 6
		selectObject: "TextGrid merged"
		startVV = Get start time of interval... 5 'a'
		endVV = Get end time of interval... 5 'a'
		durVV = endVV - startVV
		startPhone = Get start time of interval... 6 'a'
		endPhone = Get end time of interval... 6 'a'
		durPhone = endPhone - startPhone
			if 'durPhone:3' < 'durVV:3'
				Remove right boundary... 6 'a'
			elsif 'durPhone:3' >= 'durVV:3'
				a = a + 1
			endif
		n_intPhone = Get number of intervals... 5
		n_intVV = Get number of intervals... 6
	until a = n_intVV

	Copy... "TextGrid merged"
	Rename... 'mausMasVV$'
	
	select TextGrid 'mausMasVV$'
	Set tier name: 5, "VVunits"
	selectObject: "TextGrid merged"
	Duplicate tier: 5, 1, "VowelOnsets"
	
	## Create chunk tier
	select TextGrid 'maus$'
	Extract one tier: 1
	selectObject: "TextGrid merged"
	Rename... "TG_temp"
	selectObject: "TextGrid _TG_temp_"
		plusObject: "TextGrid ORT-MAU"
	Merge
	
	## Removing
	selectObject: "TextGrid _TG_temp_"
		plusObject: "TextGrid ORT-MAU"
	Remove
	##

	selectObject: "TextGrid merged"
	Insert interval tier: 9, "Chunk"
	
	## For this "if loop", you choose whether you need a more detailed chunk segmentation
	## (into several chunks), or just the two-boundary tier
	if chunk_segmentation = 1
		numberOfWords = Get number of intervals: 8
		for i from 2 to numberOfWords - 1
			word_start_time = Get start time of interval: 8, i
			word_end_time = Get end time of interval: 8, i
			word_label$ = Get label of interval: 8, i
			if word_label$ = chunk_starting_word_1$ 
			... or word_label$ = chunk_starting_word_2$ 
			... or word_label$ = chunk_starting_word_3$ 
			... or word_label$ = chunk_starting_word_4$
				Insert boundary: 9, word_start_time
			elsif word_label$ = chunk_end_word$
				Insert boundary: 9, word_end_time
			endif
		endfor
		
		ch_number = 0
		numberOfChunks = Get number of intervals: 9
		for j from 2 to numberOfChunks - 1
			chunk_label$ = Get label of interval: 9, j
			if chunk_label$ = ""
				ch_number = ch_number + 1
				Set interval text: 9, j, "CH'ch_number'"
			endif
		endfor
	else
		select Sound 'sound_file$'
		To Intensity... 100 0 0 yes 
			select Intensity 'sound_file$'
			nframes = Get number of frames
		for k from 1 to nframes
			int = Get value in frame: k
			if int > 'threshold'
				time = Get time from frame: k
				selectObject: "TextGrid merged"
				Insert boundary: 9, time
			endif
			select Intensity 'sound_file$'
		endfor
		
		select Intensity 'sound_file$'
		Remove
		
		selectObject: "TextGrid merged"
		a = 3
		repeat
			intervals = Get number of intervals: 9
			Remove left boundary: 9, a
			intervals = Get number of intervals: 9
		until a = intervals
	endif

	Duplicate tier: 9, 4, "Chunk"
	repeat
 		ntiers = Get number of tiers
		t = 5
		selectObject: "TextGrid merged"
		Remove tier: 't'
		ntiers = Get number of tiers
	until ntiers = 4

	## Delete former sound file Textgrid and add chunk tier to "MAUS-MAS-VV TextGrid"
	select TextGrid 'sound_file$'
	Remove
	
	selectObject: "TextGrid merged"
	Rename... 'sound_file$'
	Extract one tier: 4
	
	select TextGrid 'mausMasVV$'
		plus TextGrid Chunk
	Merge
	
	## Removing...
	select TextGrid 'mausMasVV$'
		plus TextGrid Chunk
	Remove
	##
	
	selectObject: "TextGrid merged"
	Rename... 'mausMasVV$'

	## Saving TextGrid files
	if save_TextGrid_files = 1
		@saveTextGrid
		@percentFit
		@dataSummary
	else
		#selectObject: "TextGrid merged"
		#Rename... 'sound_file$'
		@percentFit
		@dataSummary
	endif
	
	#####-----#####-----#####-----#####-----#####-----#####
	procedure saveTextGrid
		select TextGrid 'maus$'
		Write to text file... 'maus$'.TextGrid
		#
		select TextGrid 'mausMasVV$'
		Write to text file... 'mausMasVV$'.TextGrid
		#
		select TextGrid 'sound_file$'
		#selectObject: "TextGrid merged"
		#Rename... 'sound_file$'
		Write to text file... 'sound_file$'.TextGrid
	endproc
	#####-----#####-----#####-----#####-----#####-----#####
	
	## Counting new tier intervals
	#####-----#####-----#####-----#####-----#####-----#####
	procedure percentFit
		select TextGrid 'mausMasVV$'
		vCount = Count intervals where: 1, "is equal to", "V"
		cCount = Count intervals where: 1, "is equal to", "C"
		vvCount = Count intervals where: 5, "is equal to", "VV"
		pauseCount = Count intervals where: 1, "is equal to", "#"
		phonoSylCount = Count intervals where: 3, "is equal to", "PhonoSyl"
		perc_fit = abs((phonoSylCount - vvCount))*100/(vvCount)
		perc_fit = 'perc_fit:1'
	endproc
	#####-----#####-----#####-----#####-----#####-----#####

	## Data summary
	#####-----#####-----#####-----#####-----#####-----#####
	procedure dataSummary
		appendInfoLine: soundname$, "/.TextGrid"
		appendInfoLine: ""
		appendInfoLine: 'vCount', " vowels"
		appendInfoLine: 'cCount', " consonants"
		appendInfoLine: 'pauseCount', " pauses"
		appendInfoLine: ""
		appendInfoLine: 'vvCount', " VV units"
		appendInfoLine: 'phonoSylCount', " Phonological syllables"
		appendInfoLine: "Syllable fit correction: ", 'perc_fit', "%"
		appendInfoLine: ""
		if y < numberOfFiles
			appendInfoLine: "#####"
		endif
		select TextGrid 'sound_file$'_V
			plus PointProcess 'sound_file$'_V
		Remove
	endproc
	#####-----#####-----#####-----#####-----#####-----#####
endfor

## Counting the TextGrid files (MAUS), and the new ones created: (MAUS<->Phono.Syl., and VV units)
Create Strings as file list... tgList *.TextGrid
select Strings tgList
numberOfTG = Get number of strings
	if save_TextGrid_files = 1
		appendInfoLine: "--------------------"
		appendInfoLine: 'numberOfFiles', " '.WAV' files, and ", 'numberOfTG', " '.TextGrid' files 
		... were created in the folder:"
		appendInfoLine: folder$
		select Strings audioDataList
			plus Strings tgList
		Append
		appended_string_name$ = "AudioTextGridList"
		Rename... 'appended_string_name$'
		select Strings audioDataList
			plus Strings tgList
		Remove
		select Strings AudioTextGridList
	else
		select all
		sound_objects = numberOfSelected ("Sound")
		tg_objects = numberOfSelected ("TextGrid")
		appendInfoLine: "--------------------"
		appendInfoLine: 'sound_objects', " '.WAV' files, and ", 'tg_objects', " '.TextGrid' files
		... were created in the Praat objects window"
		select Strings audioDataList
			plus Strings tgList
		Append
		appended_string_name$ = "AudioTextGridList"
		Rename... 'appended_string_name$'
		select Strings audioDataList
			plus Strings tgList
		Remove
		select Strings AudioTextGridList
		#Write to binary file... 'folder$'\praat.Collection
	endif
#select all
#Remove