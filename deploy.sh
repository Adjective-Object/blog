#/usr/bin/env bash

make site
if [ $? -ne "0" ]; then
	echo "error in building site binary"
	exit 1
fi

./site build
if [ $? -ne "0" ]; then
	echo "error in building site"
	exit 1
fi


git checkout gh-pages
if [ $? -ne "0" ]; then
	echo "error in checking out gh-pages"
	exit 1
fi

rsync --remove-source-files _site/* .
if [ $? -ne "0" ]; then
	echo "error in moving _site contents"
	exit 1
fi

git add .
if [ $? -ne "0" ]; then
	echo "error adding files"
	exit 1
fi

current_time=`date`
if [ $? -ne "0" ]; then
	echo "error in getting date"
	exit 1
fi

git commit -am "build at $current_time"
if [ $? -ne "0" ]; then
	echo "error in git commit"
	exit 1
fi
