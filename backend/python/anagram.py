'''
IAM Role Access

 {
            "Action": [
                "s3:ListBucket"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:s3:::words-txt-test"
        },
        {
            "Action": [
                "s3:GetObject"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:s3:::words-txt-test/*"
        }

'''

import time
import itertools
import os
import re
import boto3

def main(inputWord, includeSourceWord):
	returnData = {"success" : False}

	try:
		# Make sure the parameter passed in is a String
		inputWord = str(inputWord)

		# If the input letters make a real word should this be included also?
		if includeSourceWord != True and includeSourceWord != False:
			includeSourceWord = True

		# Hardcoded minimum length word
		shortestWordLen = 4
		# Hardcoded maximum allowed word length - just to force an exception, so the below functionality will work as intended
		maxAllowedMax = 9

		# Validate word
		pattern = r"^[A-Za-z]{{{},{}}}$".format(shortestWordLen, maxAllowedMax)	# Only allow English characters between the allowed word length range
		# Use Regex to only allow English letters
		while re.search(pattern, inputWord) == None:
			# If the length is correct, display an error regarding invalid characters
			if len(inputWord) >= shortestWordLen and len(inputWord) <= maxAllowedMax:
				s = "ERRROR : Invalid characters entered, please try again. Only allowed to be English letters (Eg A-Z). Characters entered : [ {} ]".format(inputWord)
				raise Exception(s)
		
		startTime = time.time()			# Used for printline testing

		# Just for testing
		doPrintLines = True

		# The source data to be used for reference is Lower Case - and remove all white space
		inputWord = ''.join(inputWord.lower().split())

		# The possible letters of the input word
		possibleLetters = []
		# The numeric indexes of this input word
		lettersIndexes = []

		# The main string array where all possible new words will be added
		newWords = set()
		# The actual checked words - real possible words against generated letter words
		realWordOutput = set()
		# To sort the real words by length and alphabetically
		sortedWordLengthOutput = {}

		# The final sorted output
		finalRealWordOutput = []

		# Eg how many letters there are in the word - used for many loops below
		maxPossibleIndexVal = 0	# Note the value is not important, just to set it as an Int

		# Generate the possible letters and indexes of these from the input work
		for wordIdx in range(0,len(inputWord)):
			possibleLetters.append(inputWord[wordIdx])
			lettersIndexes.append(wordIdx+1)
		# sort these
		lettersIndexes.sort()
		possibleLetters.sort()

		# Get the highest index value from this - which would be the length of the input word
		if len(lettersIndexes) > 0:
			for idx in range(len(lettersIndexes), 0, -1):
				if maxPossibleIndexVal < idx:
					maxPossibleIndexVal = idx

		# Throw an exception as a safeguard
		if maxPossibleIndexVal > maxAllowedMax:
			s = "ERRROR : 'maxPossibleIndexVal' variable value ({}) is above the allowed 'maxAllowedMax' variable value ({}) - cannot continue with the current functionality".format(maxPossibleIndexVal, maxAllowedMax)
			raise Exception(s)
		elif maxPossibleIndexVal< shortestWordLen:
			s = "ERRROR : 'maxPossibleIndexVal' variable value ({}) is below the allowed 'shortestWordLen' variable value ({})".format(maxPossibleIndexVal,shortestWordLen)
			raise Exception(s)

		# ************************************************************************************************************
		# Make possible numbers from the word - To be then used as indexes to loop through the string word
		# Eg for a 4 letter word this would go from 12345 to 54321, without duplicate digits

		# Indexes of the Word letters as strings of the value
		allowedIndexStrVals = []
		# All possible numbers generated from the indexes of the input work, to be used to create the output string words
		allPossibleWordRangeValues = set()

		# Stringify the allowed index values
		for letterIdx in lettersIndexes:
			allowedIndexStrVals.append(str(letterIdx))

		# Loop through the possible length words from the hardcoded character minimum up to the full length of the input work itself
		for wordLength in range(shortestWordLen, maxPossibleIndexVal+1):
			# Create blank object lists for each word list - to be used for the final output
			sortedWordLengthOutput[wordLength] = []
			# Generate all unique index combinations using itertools library permutations
			for indexes in itertools.permutations(lettersIndexes, wordLength):
				# For all possible index values, convert them to a string and then check that they do not contain any duplicate or invalid numbers
				# eg 11345 is invalid because of the two 1's, as is 12349 due to the 9
				intVal = int(''.join(str(idx) for idx in indexes))
				# And then store these unique valid values
				allPossibleWordRangeValues.add(intVal)

		# ************************************************************************************************************
		# Generate theoretically possible string synonyms from the singular input word from these numerical indexes

		# Basically just random strings from the letters of the input word - likley to be many thousands of possibilities for a long word
		# Eg "ABCD" though to "DCBA" for input word ABCD

		for num in allPossibleWordRangeValues:
			# Eg num = 1234 or 53214 etc
			theLetters = []
			for thisLetterIdx in str(num):
				# Create an array of the letters of the new possible word based on the index number
				# Eg 1234 would be the first index of a four letter word
				# Eg 4321 of input "ABCD" would return "D,C,B,A" in an array
				theLetters.append(inputWord[int(thisLetterIdx)-1])
			# And then create the string word from these individual letters
			theWord = ""
			for letter in theLetters:
				# Eg first loop of ["A","B","C","D"] - created from the possible letters of above "num" variable (if 1234) from original word ABCD
				theWord = theWord + letter
			# Add to the final array if is unique
			if theWord not in newWords:
				# Note at the moment its all possible letters - so "ABCD" is included, even though is not a real word obviously
				newWords.add(theWord)
				# testing
				# if theWord == inputWord:
				# 	print("The word itself {} is included".format(theWord))

		# ************************************************************************************************************
		# Compare against a static list of real existent words stored in an S3 currently - to return actual read words only
		if len(newWords) > 0:
			s3 = boto3.client("s3")
			bucket_name = "words-txt-test"		# Hardcoded bucket name ### use an Environment Variable
			objects_list = s3.list_objects_v2(Bucket=bucket_name).get("Contents")	# the objects stored in the S3 Bucket - eg the files
			# loop through the files
			for obj in objects_list:
				obj_name = obj["Key"]
				fileName = str(obj_name).lower().lstrip().rstrip()
				# Must be a TXT file
				if fileName.endswith(".txt"):
					includeFile = True
					sVal = fileName.split(".txt")[0]
					# Whose filename is a numeric value only
					if sVal.isdigit():
						val = int(sVal)
						if val < shortestWordLen or val > maxPossibleIndexVal:
							includeFile = False
					# If is a valid file
					if includeFile:
						objectResponse = s3.get_object(Bucket=bucket_name, Key=obj_name)	# raw meta data of the file object
						object_content = objectResponse["Body"].read().decode("utf-8")		# contents of the file object
						# The contents of the files are one word per line
						stripped = object_content.split('\n')
						# add the words into a Set
						realWordsList = { line.strip().lower() for line in stripped if line.strip() != '' }
						# Then loop through this created list (set)
						for realWord in realWordsList:
							# If the real word does exist in the generated "words"
							if realWord in newWords:
								# Then add to the output - That is the final output of real words - just not yet sorted
								realWordOutput.add(realWord.upper())

		# ************************************************************************************************************
		# Then sort this list of real words by length and alphabetically
		inputWord = inputWord.upper()
		if len(realWordOutput) > 0:
			# Loop through possibly word lengths
			for wordLength in range(shortestWordLen, maxPossibleIndexVal+1):
				# Set a blank list
				wordsList = []
				# Loop through the non-sorted real words Set
				for real in realWordOutput:
					# If the length of the word is this word length
					if len(real) == wordLength:
						# Then add to this list
						wordsList.append(real)
				# Then sort this alphabetically
				wordsList.sort()
				# Then add to this object attached to the word length value
				sortedWordLengthOutput[wordLength] = wordsList
		# Then loop through the alphabetically sorted word length object
		for wordLength in sortedWordLengthOutput:
			for word in sortedWordLengthOutput[wordLength]:
				# And add these words to the final output - ordered first by word length and then alphabetically
				if word != inputWord or includeSourceWord:
					finalRealWordOutput.append(word)

		endTime = time.time()	# Used for printline testing

		outputTextNote = ""

		# Print Line for testing
		if doPrintLines:
			print()
			print(finalRealWordOutput)		# Note this is the data that will eventually be returned
			print()

			if len(finalRealWordOutput) == 0:
				outputTextNote = "No real words can be generated from input word : '{}'".format(inputWord)
				print(outputTextNote)
				outputTextNote = outputTextNote + "\n"
				print()

			outputTextNote = outputTextNote + "An [{}] letter input word ('{}') generates [{}] possible randomised words, of which [{}] are actually real words - taking {:.3f} seconds in an Python AWS Lambda".format(len(inputWord),inputWord,len(newWords),len(finalRealWordOutput),endTime - startTime)
			print(outputTextNote)
			print()

		returnData["lenDict"] = sortedWordLengthOutput
		returnData["rawList"] = finalRealWordOutput
		returnData["wordCount"] = len(finalRealWordOutput)
		returnData["success"] = True
		returnData["note"] = outputTextNote
		print(returnData)

	except Exception as e:
		print(e)

	return returnData