#/bin/sh

### Constants ###

if [ $1 == '--clean' ]; then
    CLEAN=0
    BASE_DIR=$2
else
    CLEAN=1
    BASE_DIR=$1
fi

### Helper Functions ###

function directory_contains_image {
    # If there is any image
    if find $1 -maxdepth 1 | egrep '\.png$|\.jpg$|\.jpeg$|\.gif$|\.tiff$' > /dev/null ; then
	return 0
    else
	return 1
    fi
}

function create_directory_for {
    if directory_contains_image $1 ; then
	echo 'Creating directory android in ' $1 '...'
	mkdir -p $1/android
	echo '[Done]'
    else
	echo "No image were found in ' $1 ' directory...\n [Did nothing]"
    fi
}

function remove_directory_for {
    if directory_contains_image $1 ; then
	echo 'Removing directory android in ' $1 '...'
	rm -rf $1/android
	echo '[Done]'
    else
	echo "No image were found in ' $1 ' directory...\n [Did nothing]"
    fi
}

function copy_images_from {
    if directory_contains_image $1 ; then
	echo 'Copying from ' $1 '...'
	cp -v `find $1 -maxdepth 1 | egrep '\.png$|\.jpg$|\.jpeg$|\.gif$|\.tiff$'` $1/android
	echo '[Done]'
    fi
}

function create_images {
    echo 'Converting iPhone base images to Android medium devices...'
    for IMAGE in `find $1/android -maxdepth 1 | egrep '\.png$|\.jpg$|\.jpeg$|\.gif$|\.tiff$'`
    do
	ext=`echo $IMAGE | sed 's/.*\.//g'`
	mv -v ${IMAGE} ${IMAGE/%.$ext/-medium.$ext}
    done
    echo '[Done]'
    echo 
    echo 'Converting iPhone Retina images to Android (x)high devices...'
    for IMAGE in `find $1/android -maxdepth 1 | egrep '\.png$|\.jpg$|\.jpeg$|\.gif$|\.tiff$'`
    do
	ext=`echo $IMAGE | sed 's/.*\.//g'`
	echo 'Copying ' $IMAGE '...'
	cp -v ${IMAGE} ${IMAGE/%@2x-medium.$ext/-high.$ext}
	echo 'Moving ' $IMAGE '...'
	mv -v ${IMAGE} ${IMAGE/%@2x-medium.$ext/-xhigh.$ext}
    done
    echo '[Done]'
    echo 
}

function resize {
    echo 'Resizing all images in ' $1/android/ '...'
    mogrify -resize 75% `find $1/android -maxdepth 1 | egrep '\-high\.png$|\-high\.jpg$|\-high\.jpeg$|\-high\.gif$|\-high\.tiff$'`
    echo '[Done]'
}

### Script ###

echo '[STARTING]'
for NODE in `find $BASE_DIR`
do
    if ([ -d $NODE ] && directory_contains_image $NODE ); then
	if [ $CLEAN == 0 ]; then
	    remove_directory_for $NODE
	else
	    echo $NODE
	    create_directory_for $NODE
	    echo
	    copy_images_from $NODE
	    echo
	    create_images $NODE
	    resize $NODE
	fi
	echo 
	echo
    fi
done

echo '[ALL DONE]'