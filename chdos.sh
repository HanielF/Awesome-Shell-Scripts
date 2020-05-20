#!/bin/bash
while [ "$#" -ge 1 ];
do
	iconv -f UTF-8 -t GBK $1 -o $1
	unix2dos $1
	shift
done

exit 0;
