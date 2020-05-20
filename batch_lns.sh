#!/bin/bash
# Create symbolic link in bulk
source_path=$1
tar_path=$2
file_ext=$3
cur_path=$(pwd)

# Get absolute path of source_path and tar_path
echo "======Usage: batch_lns dir1 dir2 file_type======"
echo "======Please Check The Path and File Type======"
cd $source_path
source_path=$(pwd)
echo "Source Path: $source_path"
cd $cur_path;cd $tar_path
echo "Target Path: $tar_path"
tar_path=$(pwd)
cd $cur_path
echo "File Type: $file_ext"

# Check whether the path is right
read -p "Is Everything Right(Y/N): " ans
if [ "$ans" != 'Y' ] && [ "$ans" != 'y' ] && [ "$ans" != '' ]; then exit; fi

# Ln origin file to target file
echo "======Start Creating Soft Links======"
for i in `find $source_path -iname "*.$file_ext"`
do
	#only keep file name
	file_name=${i##*/}
  #remove file type in file name
  file_name=${file_name%.*}

	echo "ln $i to $tar_path/$file_name"
  # check if the link exists
  if [ -f $tar_path/$file_name ];then
    read -p "Do you want to replace the existing symbolic link (Y/N):" ans
    if [ "$ans" != 'Y' ] && [ "$ans" != 'y' ] && [ "$ans" != '' ]; then
      continue
    else
      sudo rm -f $tar_path/$file_name
    fi
  fi

  # create current symbolic link
  sudo ln -s ${i}  $tar_path/$file_name
  
  # if get authentication failed, exit the script
  if [ $? -ne 0 ]; then
    exit
  fi
done

# exit script
echo "======Finish Creating Soft Links======"
