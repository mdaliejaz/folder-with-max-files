#!/bin/bash

progress(){
	echo -n "Please wait..."
	while true ; do
     		echo -n "."
     		sleep 0.1
	done
}

# sorting in descending order. Using bubble sort as want to sort (key,value) pair. Don't know how to use linux 'sort' on 2 arrays at the same time.
inverse_bubble_sort(){  
	for (( last=$((${#key[@]} - 1));last>0;last--)) ; do
    		for((counter=0;counter<last;counter++)) ; do
			j=$((counter+1))
      			if [ ${key[counter]} -lt ${key[j]} ] ; then
				temp_key=${key[$counter]}
				temp_result=${result[$counter]}
				key[$counter]=${key[$j]}
				result[$counter]=${result[$j]}
				key[$j]=$temp_key
				result[$j]=$temp_result
			fi
    		done
	done
}

# Function to count subdirectory contents
go_ahead(){ 
	counter=0
	for dir in $(find $directory_to_search -maxdepth 1 -type d); do
		if [ -d $dir ] && [ $dir != $directory_to_search ] ; then 
			result[$counter]=$(echo -e "$dir :\t `ls $dir | wc -l`")
			key[$counter]=$(echo `ls $dir | wc -l`)
			((++counter))
		fi
	done 

	inverse_bubble_sort $result $key

	if [ $directories_to_list -eq 0 ] ; then
		directories_to_list=${#result[@]}
	fi

	echo
	counter=0
	while [ $counter -lt $directories_to_list ] ; do
  		echo "${result[$counter]}"
		((++counter))
	done
}

START=$(date +%s)

# Starting progress in the background
progress &

# Save progress PID
progress_pid=$!

# Changing the Internal Field Separator, so that spaces in subdirectory names are considered
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

directories_to_list=0
if [ $# -eq 0 ] ; then
	echo
	echo -n "You have not specified any path. Looking for sub-directories in the current folder and listing all in descending order"
	directory_to_search=$(pwd)
else
	directory_to_search=$1
	if [ $# -ge 2 ] ; then
		if [ $2 -eq 0 -o $2 -ne 0 ] ; then
				directories_to_list=$2
			else
				echo
				echo -n "The script doesn't accept anything other than integer as it's second argument.  This execution will be listing all the subdirectories in descending order"
		fi
	else
		echo
		echo -n "To list top 'N' number of sub-directories specify 'N' as the second argument. This execution will be listing all the subdirectories in descending order"
	fi
fi

if [ $(find $directory_to_search -maxdepth 1 -type d | wc -l) -eq 1 ] ; then
	echo
	echo "There is no subdirectory inside the path mentioned"
else
	go_ahead $directory_to_search $directories_to_list
fi

# Restoring the default IFS
IFS=$SAVEIFS

END=$(date +%s)
DIFF=$(($END-$START))
echo "Time taken to execute: $DIFF seconds"

# Kill progress
kill $progress_pid &>/dev/null

