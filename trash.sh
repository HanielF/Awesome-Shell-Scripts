#!/bin/bash
# A script for backing up your files that to be deleted with command `rm`
# The files will be moved to system trash directory
# You need to alias trash to rm command
DATE=`date +%Y-%m-%dT%H:%M:%S`
# TRASH_FILE="~/.local/share/Trash/files"
TRASH_FILE="/home/hanielxx/.local/share/Trash/files"
TRASH_INFO="/home/hanielxx/.local/share/Trash/info"
# TRASH_INFO="~/.local/share/Trash/info/"
CUR_PATH=$(pwd)


# ======function define======
# help function
trash_help () {
	cat <<eof
usage1: `basename $0` file1 [file2] [dir3] [....] delete the files or dirs,and mv them to the system trash
usage2: rm    file1 [file2] [dir3] [....] delete the files or dirs,and mv them to the system trash 
        Command rm needs to be aliased as `basename $0`
        The system trash is located in .local/share/Trash/
options:
	-f/r/fr/rf  mv one or more files to the system trash 
	-l  list the contens of system trash
	-i  show detailed log of the deleted file history
	-h  display the help menu
eof
}
# -d  delete one or more files by user's input file name from the trash
# -e  empty the system trash

# rm_list function
rm_list () {
  echo ------Current Status of System Trash------
  ls --color -al $TRASH_FILE
}

# rm_infolog function: show delete log
rm_infolog () {
  echo ------Log Information of System Trash------
	cat $TRASH_INFO/* | sed '1d' | sed '/Trash Info/c \ '
}


# rm_mv function: move file to system trash
rm_mv () {
  echo -e "\033[33m==>\033[0m Files Will Be Moved To System Trash"
  echo
	now=`date +%Y-%m-%dT%H:%M:%S`
  # get full path of current file
  file_name=`basename $1`	
  file_dir=$(cd `dirname $1`;pwd)
  file_fullpath=$file_dir/$file_name
  # echo file_name: $file_name
  # echo file_dir: $file_dir
  # echo file_fullpath: $file_fullpath

  if [[ "$file_fullpath" == "/*" || "$file_name" == "/" ]];then
    echo -e "\033[5m\033[31m==>\033[0m\033[0m Action Deny!"
    exit 1
  fi

  # recurrently move file to system trash
  if [[ -f $file_fullpath ]]; then
    # if file exists in trash, then rename it as *.2.filetype
    if [[ -f $TRASH_FILE/$file_name ]]; then
      file_type=${file_name##*\.}
      raw_name=${file_name%.*}
      echo file_type:$file_type
      echo raw_name:$raw_name
      trash_dest_name="$raw_name.2.$file_type"
      echo -e "\033[32m==>\033[0m Note: $file_name is already existing in trash! Rename it as $trash_dest_name"
    else
      trash_dest_name=$file_name
    fi
    
    # move file to trash and write to log info
    mv $file_fullpath $TRASH_FILE/$trash_dest_name
    touch $TRASH_INFO/$trash_dest_name.trashinfo
    echo -e "[Trash Info]\nPath=$file_fullpath\nDeletionDate=$now" >> $TRASH_INFO/$trash_dest_name.trashinfo
    echo -e "\033[33m==>\033[0m Move $file_fullpath --> $TRASH_FILE/$trash_dest_name"

  elif [[ -d $file_fullpath ]]; then
    echo -e "\033[33m==>\033[0m Removing $file_fullpath:"
    dirlist=$(ls $file_fullpath)
    # delete files recursively
    for subfile in ${dirlist[*]}
    do
      rm_mv $file_fullpath/$subfile
    done
  fi
  echo 
  echo -e "\033[33m==>\033[0m Done! Deleted Files Can Be Restored From '~/.local/share/Trash/files/' With System File Manager"
  echo -e "\033[33m==>\033[0m You Can Review Log Info in '~/.local/share/Trash/info/'."
}


# Main
if [ $# -eq 0 ] ;then trash_help ;fi
while getopts lRiecdhfr option ;do
case "$option" in
		l) rm_list;;
		# R) rm_list
			 # rm_restore;;
    i) rm_infolog;;
    h) trash_help;;
		# e) rm_empty;;
    # c) rm_delete_by_30_days;;
    # d) rm_list
       # rm_delete;;
    \?)trash_help
       exit 0;;
	esac
done
shift $((OPTIND-1))

#将文件名的参数依次传递给rm_mv函数
while [ $# -ne 0 ];do
	file=$1
	rm_mv $file
  # delete the directory
  echo "while file= $file"
  if [[ -d $file ]]; then
    rm -r $file
    echo "Remove Directory $file"
  fi
	shift
done

exit 0
