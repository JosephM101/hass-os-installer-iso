build_dir="build"

make_symlink() {
    if [ ! -e ./$build_dir/$1 ]; then
       echo "Creating symlink for $1"
       ln -s ../$1 ./$build_dir/$1
    else
        echo "Symlink for $1 already exists, skipping"
    fi
}

copy_dir() {
    if [ -e $2 ]; then
       rm -rf $2  # delete the target directory
    fi
    echo "Copying $1 to $2..."
    cp -r $1 $2  # recursively copy source directory ($1) to target ($2)
}


echo "Initializing build directory"
# Create build dir if it doesn't exist
if [ ! -e $build_dir ]; then
    mkdir -p $build_dir
fi


make_symlink auto
make_symlink build-config
copy_dir config $build_dir/config
# touch $build_dir/.build
echo "Done"
