#/usr/bin/env bash

make site-static
if [ $? -ne "0" ]; then
	echo "error in building site binary"
	exit 1
fi

./site-static build
if [ $? -ne "0" ]; then
	echo "error in building site"
	exit 1
fi


git checkout gh-pages
if [ $? -ne "0" ]; then
	echo "error in checking out gh-pages"
	exit 1
fi

cp -r _site/* .
if [ $? -ne "0" ]; then
	echo "error in moving _site contents"
	exit 1
fi

rm -r _site/

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

git commit "https://${GH_TOKEN}@${GH_REF} master:gh-pages" 2>&1 > /dev/null
if [ $? -ne "0" ]; then
	echo "error in git commit"
	exit 1
fi
