#!/bin/bash
while [ "$#" -ge 1 ];
do
	iconv -f GBK -t UTF-8 $1 -o $1
	dos2unix $1
	shift
done

exit 0;
