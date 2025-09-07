# List of [git diff] file names

# Including both tracked as well as *Untracked* - which is the main reason this was created - eg "gitk"
# Note empty folders will not be included as Git does not track these

# Run :
# "bash git-diff.sh" : for format A
# or
# "bash git-diff.sh a" : for format B (actual parameters are irrelevant - just checks if they exist)

# Check if current directory (where the script is ran from) is actually within a valid Git repo
isGit=0
if [ -d .git ]; then
	isGit=1
elif git rev-parse --git-dir > /dev/null 2>&1; then
	isGit=1
fi

if [[ "$isGit" -eq 1 ]]; then

	# Display some details for reference
	echo -e "Branch :\t $(git rev-parse --abbrev-ref HEAD)";
	echo -e "Repo :\t\t $(git config --get remote.origin.url)";
	echo -e "User: \t\t $(git config user.name) : <$(git config user.email)>";
	echo ""

	# Common display/filtering data
	# A brand new file which has been been staged yet - note this would also included renamed files, as this is not tracked until staged
	keyBrandNew="1.B"
	textBrandNew="Brand New"
	# A newly added file which has been staged
	keyAdded="2.A"
	textAdded=Added
	# A newly added file which was staged, but has since had later changes and thus unstaged
	keyAddedButChanged="3.AU"
	textAddedButChanged="Added-Unstaged"
	# A previously committed file which has new changes, and has also been staged
	keyModified="4.M"
	textModified="Modified-Staged"
	# A modified existing file which has unstaged changes - either never staged or staged and then changed again
	keyModifiedButChanged="5.MU"
	textModifiedButChanged="Modified-Unstaged"
	# A deleted file which has not been staged yet, this would also included renamed files
	keyDeleted="6.D"
	textDeleted="Deleted-Unstaged"
	# A deleted file which has now been staged
	keyDeletedStaged="7.DS"
	textDeletedStaged="Deleted-Staged"
	# Possibly never used?
	keyTracked="8.T"
	textTracked=Tracked

	# Get all changed files at once in a variable
	changedFiles=$(
		(
			git diff --cached --name-only													# Newly created staged but not yet committed
			git diff --name-only															# Staged files which have already been committed previously
			git ls-files --others --exclude-standard										# Untracked new files - eg never staged
			git diff --cached --name-status --diff-filter=R | awk '{print $2; print $3}'	# Both old and new names of renamed staged files
		) | sort -u
	)

	# If no files are returned in the git data which have changes but not committed
	if [ -z "$changedFiles" ]; then
		echo "No files have changes which are not yet committed"
	# Continue with the main functionality
	else

		# Boolean used to determine the output dislay type
		lineVersion=0
		if [ $# -gt 0 ]; then
			# If parameters are passed in display the "line version", otherwise the default is by grouping
			lineVersion=1
		fi

		# # Use this for debugging ##
		# echo "$changedFiles" | while read -r file; do
			# echo "File: $file"

			# # Eg : 
			# echo "Staged: $(git diff --cached --name-only | grep -Fx "$file")"

			# echo "---"
		# done

		# First loop - get the files as well as their status
		fileData=$(echo "$changedFiles" | while read -r file; 
			do
				# Has the file been committed previously?
				existsInHEAD=$(git cat-file -e HEAD:"$file" 2>/dev/null && echo "yes" || echo "")
				# Is renamed?
				renamed=""
				partOfRename=$(git diff --cached --name-status --diff-filter=R | awk -v f="$file" '$2==f||$3==f')
				if [[ -n $partOfRename ]]; then
					renamed=" (Renamed)"
				fi 

				# If the file has at least been staged and/or committed previously
				if git ls-files --error-unmatch "$file" > /dev/null 2>&1; then
					if ! [ -e "$file" ]; then
						# This works for unstaged deleted files
						status=$keyDeleted
						label=$([ "$lineVersion" -eq 1 ] && echo "($textDeleted)  : " || echo "$textDeleted")
					else
						# Check if the file has been Staged or not
						staged=$(git diff --cached --name-only | grep -Fx "$file")
						unstaged=$(git diff --name-only | grep -Fx "$file")
						
						if [[ -n $staged && -n $unstaged && -z $existsInHEAD ]]; then
							# Added but later changed (new unstaged changes exist for this never committed file)
							status=$keyAddedButChanged
							label=$([ "$lineVersion" -eq 1 ] && echo "($textAddedButChanged)    : " || echo "$textAddedButChanged")
						elif [[ -n $staged && -z $unstaged && -z $existsInHEAD ]]; then
							# Newly created files which are Staged
							status=$keyAdded
							label=$([ "$lineVersion" -eq 1 ] && echo "($textAdded)             : " || echo "$textAdded")
						elif [[ -n $staged && -z $unstaged && -n $existsInHEAD ]]; then
							# Previously committed files whose contents have been modified
							status=$keyModified
							label=$([ "$lineVersion" -eq 1 ] && echo "($textModified)   : " || echo "$textModified")
						elif [[ -n $unstaged && -n $existsInHEAD ]]; then
							# This previously committed file has new staged changes, but has subsequently been changed after that
							status=$keyModifiedButChanged
							label=$([ "$lineVersion" -eq 1 ] && echo "($textModifiedButChanged) : " || echo "$textModifiedButChanged")
						else
							# This is probably never used
							status=$keyTracked
							label=$([ "$lineVersion" -eq 1 ] && echo "($textTracked)       : " || echo "$textTracked")
						fi
					fi
				else
					# If the file is previously committed
					if [[ -n $existsInHEAD ]]; then
						# Then it must mean that is is Deleted (Renamed) and staged
						status=$keyDeletedStaged
						label=$([ "$lineVersion" -eq 1 ] && echo "($textDeletedStaged)    : " || echo "$textDeletedStaged")
					else
						# Otherwise would be a Brand New files which have been created but not yet staged even
						status=$keyBrandNew
						label=$([ "$lineVersion" -eq 1 ] && echo "($textBrandNew)         : " || echo "$textBrandNew")
					fi
				fi

				# The output - used in subsequent loops
				echo -e "$file\t$status\t$label\t$renamed"

			done)

		# Display version - based on if parameters are passed in or not
		if [ "$lineVersion" -eq 1 ]; then

			# ============================================================================================================================================
			# Format A
			# If any parameters are passed in then display the type of every line along with the file name
			# Note the count of parameters and their contents is actually irrelevant

			# The output will be something like:
			#
			# 		(Brand New)         :  /comparison-engine/quote2.html
			# 		(Brand New)         :  /documentation/handy-notes2.txt
			# 		
			# 		(Added)             :  /123.txt
			# 		
			# 		(Added-Unstaged)    :  /zzz.txt
			# 		
			# 		(Modified-Staged)   :  /git-diff.sh
			# 		
			# 		(Modified-Unstaged) :  /readme.md
			# 		
			# 		(Deleted-Unstaged)  :  /comparison-engine/quote.html
			# 		(Deleted-Unstaged)  :  /documentation/handy-notes.txt
			#	

			# Collect the reformatted output lines from the loop
			processedLines=$(while IFS=$'\t' read -r file status label renamed; 
				do
					if [[ "$file" == */* ]]; then
						echo -e "$status\t${file}\t$label /$file\t$renamed"
					else
						echo -e "$status\t$(basename "$file")\t$label /$(basename "$file")\t$renamed"
					fi
				done <<< "$fileData")

			# Pipe all collected output through awk/sort pipeline for final formatting
			# The output display - note the numeric values are based on the order of the fields from the echo(s) above - eg "status" field is 1
			echo "$processedLines" | \
			awk -F'\t' '{
				depth = gsub(/\//,"",$2);
				print $1 "\t" depth "\t" $2 "\t" $3 "\t" $4
			}' | sort -k1,1 -k2,2n -k3,3 | \
			awk -F'\t' '
				BEGIN { prev="" }
				{
					if (prev != $1) {
						if (NR > 1) print "";
						prev = $1;
					}
					print $4 "\t" $5
				}'
		
		else

			# ============================================================================================================================================
			# Format B
			# Otherwise if no input parameters passed in (eg the default), then display the files separated by group

			# The output will be something like:
			#
			#       [Brand New]:
			#       /zzz.txt
			#       /comparison-engine/quote2.html
			#       
			#       [Added]:
			#       /xyz.txt
			#       
			#       [Added-Edit]:
			#       /git-diff.sh
			#       
			#       [Modified]:
			#       /comparison-engine/comparison-engine.ts
			#       
			#       [Modified-Edit]:
			#       /readme.md
			#       
			#       [Deleted]:
			#       /comparison-engine/quote.html
			#	

			# Collect the reformatted output lines from the loop
			processedLines=$(while IFS=$'\t' read -r file status label renamed; 
				do
					# Prepend slash for display if not present
					if [[ "$file" == /* ]]; then
						display_path="$file"
					else
						display_path="/$file"
					fi

					# Print as tab-separated: status, depth, path, label
					depth=$(grep -o "/" <<< "$file" | wc -l)
					echo -e "$status\t$depth\t$display_path\t$label\t$renamed"
				done <<< "$fileData")

			# Pipe all collected output through awk/sort pipeline for final formatting
			echo "$processedLines" | \
				# sort based on the order of the fields in the echo above - eg "status" field is 1
				sort -k1,1 -k2,2n -k3,3 | \
				# The output display - the numeric values are from the order of the fields in the echo above
				awk -F'\t' '
					BEGIN { prev = ""; }
					{
					if ($1 != prev) {
						if (NR > 1) print "";
						print "[" $4 "]" ":";
						prev = $1;
					}
					print $3 "\t" $5;
				}				
				'

		fi

	fi

	echo "";
else
	echo "This directory is not contained within a valid Git Repo.";
fi